Puppet::Type.type(:modified_properties_file).provide(:modified_properties_provider) do

  def refresh
    original = template_values
    result = template_values.merge resource[:values]

    unless resource.allow_new?
      extra = result.keys - original.keys
      unless extra.empty?
        fail "Parameter allow_new not set, but there are extra keys: #{extra}"
      end
    end

    write(result, resource[:target])
  end

  def current_values
    return @current_values unless @current_values.nil?
    return :absent unless File.file? resource[:target]

    @current_values = load resource[:target]
  end

  private

  def template_values
    load resource.template_file
  end

  def write(*args)
    require 'java-properties'
    JavaProperties.write *args
  end

  def load(*args)
    require 'java-properties'
    JavaProperties.load *args
  end

end
