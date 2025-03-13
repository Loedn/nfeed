class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank? && !options[:allow_blank]
    
    # More lenient URL validation
    valid = begin
      uri = URI.parse(value)
      uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    rescue URI::InvalidURIError
      false
    end
    
    record.errors.add(attribute, options[:message] || "is not a valid URL") unless valid
  end
end 