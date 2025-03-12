class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.present? && value =~ /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix
      record.errors.add(attribute, options[:message] || "is not a valid URL")
    end
  end
end 