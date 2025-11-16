module ApplicationHelper
    def active_if(controller:)
    'active' if params[:controller] == controller.to_s
    end
end
