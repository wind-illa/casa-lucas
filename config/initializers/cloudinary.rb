if Rails.env.development? || Rails.env.test?
  Cloudinary.config do |config|
    config.cloud_name = Rails.application.credentials.cloudinary[:cloud_name]
    config.api_key = Rails.application.credentials.cloudinary[:api_key]
    config.api_secret = Rails.application.credentials.cloudinary[:api_secret]
    config.secure = true
  end
end
