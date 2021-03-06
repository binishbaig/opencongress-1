# == Schema Information
#
# Table name: contact_congress_letters
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  disposition      :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  receive_replies  :boolean          default(TRUE)
#  contactable_id   :integer
#  contactable_type :string(255)
#  is_public        :boolean          default(FALSE)
#

require_dependency 'viewable_object'
require 'state'

class ContactCongressLetter < ActiveRecord::Base

  #========== INCLUDES
  include ViewableObject
  include ContactCongressLettersHelper

  #========== RELATIONS
  has_many :formageddon_threads, :through => :contact_congress_letters_formageddon_threads, :class_name => 'Formageddon::FormageddonThread'
  has_many :contact_congress_letters_formageddon_threads
  has_many :comments, :as => :commentable

  belongs_to :contactable, :polymorphic => true
  belongs_to :user

  #========== CONSTANTS


  #========== PUBLIC METHODS
  public

  def ident
    "ContactCongressLetter #{id}"
  end

  def to_param
    subject = formageddon_threads.first.formageddon_letters.first.subject
    subject.blank? ? "#{id}" : "#{id}-#{subject.gsub(/[^a-z0-9]+/i, '-')}"
  end

  def subject
    formageddon_threads.first.formageddon_letters.first.subject
  end

  def message
    formageddon_threads.first.formageddon_letters.first.message
  end

  def sender_full_name
    "#{formageddon_threads.first.sender_first_name} #{formageddon_threads.first.sender_last_name}"
  end

  def get_letter
    formageddon_threads.first
  end

  ##
  # Returns the the letter message and stripping away any PII using a regexp.
  # At the time of writing, 7/29/2014, this is not a good long term solution.
  # The problem is that street_address_2 was not properly storing to the UserProfile
  # model yet was being appended as part of the message body in congress letters.
  # This regexp attempts to catches PII and anything that comes after until a newline
  # appears. Unfortunately doing this may eliminate some letter text if a person
  # chooses to throw in their full name randomly in the body of their message.
  #
  def message_no_pii
    return strip_pii_from_message(get_letter(), message())
  end

  def privacy
    formageddon_threads.first.privacy
  end

  def public?
    privacy == 'PUBLIC'
  end
end
