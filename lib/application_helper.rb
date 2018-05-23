module ApplicationHelper
  # Renders the project quick-jump box
  def render_project_jump_box
    # return unless User.current.logged?
    # projects = User.current.memberships.collect(&:project).compact.select(&:active?).uniq
    projects = User.current.logged? ? User.current.memberships.collect(&:project).compact.select(&:active?).uniq : Project.all_public.select(&:active?).uniq
    if projects.any?
      options =
        ("<option value=''>#{ l(:label_jump_to_a_project) }</option>" +
         '<option value="" disabled="disabled">---</option>').html_safe

      options << project_tree_options_for_select(projects, :selected => @project) do |p|
        { :value => project_path(:id => p, :jump => current_menu_item) }
      end

      select_tag('project_quick_jump_box', options, :onchange => 'if (this.value != \'\') { window.location = this.value; }')
    end
  end
end