# frozen_string_literal: true

require "rails"
require "active_support/all"
require "decidim/core"
require "decidim/referendums/current_locale"
require "decidim/referendums/referendums_filter_form_builder"
require "decidim/referendums/referendum_slug"

module Decidim
  module Referendums
    # Decidim"s Referendums Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Referendums

      routes do
        get "/referendum_types/search", to: "referendum_types#search", as: :referendum_types_search
        get "/referendum_type_scopes/search", to: "referendums_type_scopes#search", as: :referendum_type_scopes_search
        get "/referendum_type_signature_types/search", to: "referendums_type_signature_types#search", as: :referendum_type_signature_types_search

        resources :create_referendum

        get "referendums/:referendum_id", to: redirect { |params, _request|
          referendum = Decidim::Referendum.find(params[:referendum_id])
          referendum ? "/referendums/#{referendum.slug}" : "/404"
        }, constraints: { referendum_id: /[0-9]+/ }

        get "/referendums/:referendum_id/f/:component_id", to: redirect { |params, _request|
          referendum = Decidim::Referendum.find(params[:referendum_id])
          referendum ? "/referendums/#{referendum.slug}/f/#{params[:component_id]}" : "/404"
        }, constraints: { referendum_id: /[0-9]+/ }

        resources :referendums, param: :slug, only: [:index, :show], path: "referendums" do
          resources :referendum_signatures
          member do
            get :signature_identities
            get :authorization_sign_modal, to: "authorization_sign_modals#show"
          end

          resource :referendum_vote, only: [:create, :destroy]
          resource :referendum_widget, only: :show, path: "embed"
          resources :committee_requests, only: [:new], shallow: true do
            collection do
              get :spawn
            end
          end
        end

        scope "/referendums/:referendum_slug/f/:component_id" do
          Decidim.component_manifests.each do |manifest|
            next unless manifest.engine

            constraints CurrentComponent.new(manifest) do
              mount manifest.engine, at: "/", as: "decidim_referendum_#{manifest.name}"
            end
          end
        end
      end

      initializer "decidim_referendums.assets" do |app|
        app.config.assets.precompile += %w(
          decidim_referendums_manifest.js
          decidim_referendums_manifest.css
        )
      end

      initializer "decidim_referendums.content_blocks" do
        Decidim.content_blocks.register(:homepage, :highlighted_referendums) do |content_block|
          content_block.cell = "decidim/referendums/content_blocks/highlighted_referendums"
          content_block.public_name_key = "decidim.referendums.content_blocks.highlighted_referendums.name"
          content_block.settings_form_cell = "decidim/referendums/content_blocks/highlighted_referendums_settings_form"

          content_block.settings do |settings|
            settings.attribute :max_results, type: :integer, default: 4
          end
        end
      end

      initializer "decidim_referendums.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Referendums::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Referendums::Engine.root}/app/views") # for partials
      end

      initializer "decidim_referendums.menu" do
        Decidim.menu :menu do |menu|
          menu.item I18n.t("menu.referendums", scope: "decidim"),
                    decidim_referendums.referendums_path,
                    position: 2.6,
                    active: :inclusive
        end
      end

      initializer "decidim_referendums.badges" do
        Decidim::Gamification.register_badge(:referendums) do |badge|
          badge.levels = [1, 5, 15, 30, 50]

          badge.valid_for = [:user, :user_group]

          badge.reset = lambda { |model|
            if model.is_a?(User)
              Decidim::Referendum.where(
                author: model,
                user_group: nil
              ).published.count
            elsif model.is_a?(UserGroup)
              Decidim::Referendum.where(
                user_group: model
              ).published.count
            end
          }
        end
      end
    end
  end
end
