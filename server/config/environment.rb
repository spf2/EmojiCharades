# Load the rails application
require File.expand_path('../application', __FILE__)

RESULT = {:none => 0, :right => 1, :wrong => -1}

# Initialize the rails application
EmojiCharades::Application.initialize!
