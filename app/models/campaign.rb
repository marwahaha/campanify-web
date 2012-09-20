class Campaign < ActiveRecord::Base
  
  ONLINE        = "online"
  MAINTENANCE   = "maintenance"
  PENDING       = "pending"  
  
  attr_accessible :name, :plan, :slug, :user_id, :status
  belongs_to :user
  validates_presence_of :name, :plan, :slug, :user_id
  validates_uniqueness_of :name, :slug
  
  before_validation :set_slug
  after_create      :create_app
  before_update     :change_plan
  before_destroy    :destroy_app
  
  def set_status(status)
    self.update_column(:status, status)
  end
  
  def price
    Campanify::Plans.configuration(plan.to_sym)[:price]
  end
  
  private
    
  def set_slug
    self.slug = name.parameterize
  end
  
  def create_app
    self.update_column(:status, Campaign::PENDING)    
    Delayed::Job.enqueue(Jobs::CreateApp.new(self.slug))
  end
  
  def destroy_app
    self.update_column(:status, Campaign::PENDING)    
    Jobs::DestroyApp.new(self.slug).perform
  end
  
  def change_plan    
    if self.plan_was != self.plan && self.status == ONLINE
      self.update_column(:status, Campaign::PENDING)      
      Delayed::Job.enqueue(Jobs::ChangePlan.new(self.slug, self.plan))
      self.plan = self.plan_was
    end
  end
  
end
