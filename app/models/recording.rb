class Recording < ApplicationRecord
  has_one_attached :file
  
  before_create :set_key

  private
    def set_key
      self.key = SecureRandom.urlsafe_base64(4)
    end
end
