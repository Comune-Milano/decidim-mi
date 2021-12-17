# frozen_string_literal: true

Decidim.register_participatory_space(:referendums) do |participatory_space|
  participatory_space.icon = "decidim/referendums/icon.svg"
  participatory_space.stylesheet = "decidim/referendums/referendums"

  participatory_space.context(:public) do |context|
    context.engine = Decidim::Referendums::Engine
    context.layout = "layouts/decidim/referendum"
  end

  participatory_space.context(:admin) do |context|
    context.engine = Decidim::Referendums::AdminEngine
    context.layout = "layouts/decidim/admin/referendum"
  end

  participatory_space.participatory_spaces do |organization|
    Decidim::Referendum.where(organization: organization)
  end

  participatory_space.register_resource(:referendum) do |resource|
    resource.model_class_name = "Decidim::Referendum"
    resource.card = "decidim/referendums/referendum"
    resource.searchable = true
  end

  participatory_space.register_resource(:referendums_type) do |resource|
    resource.model_class_name = "Decidim::ReferendumsType"
    resource.actions = %w(vote)
  end

  participatory_space.model_class_name = "Decidim::Referendum"
  participatory_space.permissions_class_name = "Decidim::Referendums::Permissions"

  participatory_space.seeds do
    seeds_root = File.join(__dir__, "..", "..", "..", "db", "seeds")
    organization = Decidim::Organization.first

    Decidim::ContentBlock.create(
      organization: organization,
      weight: 33,
      scope: :homepage,
      manifest_name: :highlighted_referendums,
      published_at: Time.current
    )

    3.times do |n|
      type = Decidim::ReferendumsType.create!(
        title: Decidim::Faker::Localized.sentence(5),
        description: Decidim::Faker::Localized.sentence(25),
        organization: organization,
        banner_image: File.new(File.join(seeds_root, "city2.jpeg"))
      )

      organization.top_scopes.each do |scope|
        Decidim::ReferendumsTypeScope.create(
          type: type,
          scope: scope,
          supports_required: (n + 1) * 1000
        )
      end
    end

    Decidim::Referendum.states.keys.each do |state|
      Decidim::Referendum.skip_callback(:save, :after, :notify_state_change, raise: false)
      Decidim::Referendum.skip_callback(:create, :after, :notify_creation, raise: false)

      params = {
        title: Decidim::Faker::Localized.sentence(3),
        description: Decidim::Faker::Localized.sentence(25),
        scoped_type: Decidim::ReferendumsTypeScope.reorder(Arel.sql("RANDOM()")).first,
        state: state,
        signature_type: "online",
        signature_start_date: Date.current - 7.days,
        signature_end_date: Date.current + 7.days,
        published_at: Time.current - 7.days,
        author: Decidim::User.reorder(Arel.sql("RANDOM()")).first,
        organization: organization
      }

      referendum = Decidim.traceability.perform_action!(
        "publish",
        Decidim::Referendum,
        organization.users.first,
        visibility: "all"
      ) do
        Decidim::Referendum.create!(params)
      end
      referendum.add_to_index_as_search_resource

      Decidim::Comments::Seed.comments_for(referendum)

      Decidim::Referendums.default_components.each do |component_name|
        component = Decidim::Component.create!(
          name: Decidim::Components::Namer.new(referendum.organization.available_locales, component_name).i18n_name,
          manifest_name: component_name,
          published_at: Time.current,
          participatory_space: referendum
        )

        next unless component_name == :pages

        Decidim::Pages::CreatePage.call(component) do
          on(:invalid) { raise "Can't create page" }
        end
      end
    end
  end
end
