Project.instance_eval do
  # returns latest created projects
  # non public projects will be returned only if user is a member of those
  def latest(user=nil, count=5)
    visible(user)
      .order("starts_date DESC")
      .select { |p| [p] if p.ancestors.empty? }
      .first(count)
  end
end