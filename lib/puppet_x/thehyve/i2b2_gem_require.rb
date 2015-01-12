module PuppetX
module Thehyve
module I2b2GemRequire
  def gem_require(name)
    # loading gems installed during the script execution is problematic
    begin
      Gem::Specification.find_by_name name
    rescue Gem::LoadError
      # reset Gem::Specification cache
      Gem::Specification.all = nil
    end

    require name
  end
end
end
end
