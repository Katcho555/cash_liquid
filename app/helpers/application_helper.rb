module ApplicationHelper
    def active_if(controller:)
    'active' if params[:controller] == controller.to_s
    end

    def mobile_nav_active(path)
        current_page?(path) ? "mobile-nav-item active" : "mobile-nav-item"
    end
    def flash_class(type)
        case type.to_sym
        when :notice then "success"
        when :alert  then "danger"
        when :error  then "danger"
        else "info"
        end
    end

end
