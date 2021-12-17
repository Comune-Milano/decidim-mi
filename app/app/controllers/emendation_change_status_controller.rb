class EmendationChangeStatusController < ApplicationController

    # GET /change_status
    def edit
        @id = params['o'].to_s
        @state = params['s'].to_s
        @url = params['u'].to_s
        @osservazione = Decidim::Amendment.find(@id)
        @osservazione.state = @state
        @osservazione.save!
        redirect_to @url
    end     
    
end

© 2021 GitHub, Inc. 