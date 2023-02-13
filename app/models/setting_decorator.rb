Setting.instance_eval do
  def openid?
    Object.const_defined?(:OpenID) && self[:openid].to_i > 0
  end
end