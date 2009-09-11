require File.dirname(__FILE__) + '/lib/autoform'

ActionView::Base.send( :include, Autoform::ViewHelpers )