module ApplicationHelper
    def active_if(controller:)
    'active' if params[:controller] == controller.to_s
    end

    def mobile_nav_active(path)
        current_page?(path) ? "mobile-nav-item active" : "mobile-nav-item"
    end
end
