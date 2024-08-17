class ResourcesController < ApplicationController
  include JSONAPI::ActsAsResourceController

  def context = { role: 'test'}
end
