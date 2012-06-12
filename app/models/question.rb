class Question < ActiveRecord::Base
  attr_accessible :answers, :name, :parameters, :text

  validates :name, presence: true, length: { maximum: 50 },
  		uniqueness:  { case_sensitive: false }
  
  VALID_PARAMETERS_REGEX = /\A([A-Z] (\((-*)\d(\.\.|\,(\d\,)*)(-*)\d\)|\[(-*)\d\,(-*)\d\]) *)*\z/
  #validates :parameters, format: { with: VALID_PARAMETERS_REGEX }
  # if using regex, needs to cope with multidigithumbers and decimals!!!

  VALID_ANSWERS_REGEX = /\A[^`]*`(([+-\/*^\(\)A-Z]|\d)*((((cos\(|sin\()|(tan\(|acos\())|((asin\(|atan\()|(exp\(|log\())|ln\()(([+-\/*^\(\)A-Z]|\d)+))*[+-\/*^\(\)A-Z]|\d)+(`(((((cos\(|sin\()|(tan\(|acos\())|((asin\(|atan\()|(exp\(|log\())|ln\()(([+-\/*^\(\)A-Z]|\d)+))*([+-\/*^\(\)A-Z]|\d)+))*(t|f)?\z/
  validates :answers, presence: true, format: { with: VALID_ANSWERS_REGEX }
  
  VALID_TEXT_REGEX = /\A[^`]*(`(([+-\/*^\(\)A-Z]|\d)+)*((((cos\(|sin\()|(tan\(|acos\())|((asin\(|atan\()|(exp\(|log\())|ln\()(([+-\/*^\(\)A-Z]|\d)+))*([+-\/*^\(\)A-Z]|\d)+(`((((cos\(|sin\()|(tan\(|acos\())|((asin\(|atan\()|(exp\(|log\())|ln\()(([+-\/*^\(\)A-Z]|\d)+))*([+-\/*^\(\)A-Z]|\d)+)*`[^`]*)*\z/
  validates :text, presence: true, format: { with: VALID_TEXT_REGEX }

end
# all are strings
# :text uses `` to delimit parameters, which must be single uppercase letters
# :parameters are presented as space-separated uppercase letters followed by values
#   e.g. 'A (2,3,7) B (-2..2) C [0,1]' means A is 2 or 3 or 7, 
#   B is one of -2, -1, 0, 1, 2 and C is any number between 
#   0 and 1
# :name is a unique string
# :answers is a `-separated list of expressions with t or f 
#   at the end indicating whether "order matters" is true.

VALID_PARAMETERS_REGEX = /([A-Z] (\((-*)\d(\.\.|\,(\d\,)*)(-*)\d\)|\[(-*)\d\,(-*)\d\]) *)+/
VALID_ANSWERS_REGEX = /((((cos\(|sin\()|(tan\(|acos\())|((asin\(|atan\()|(exp\(|log\())|ln\()(([+-\/*^\(\)A-Z]|\d)+))*([+-\/*^\(\)A-Z]|\d)+(`((((cos\(|sin\()|(tan\(|acos\())|((asin\(|atan\()|(exp\(|log\())|ln\()(([+-\/*^\(\)A-Z]|\d)+))*([+-\/*^\(\)A-Z]|\d)+)*(t|f)?/

