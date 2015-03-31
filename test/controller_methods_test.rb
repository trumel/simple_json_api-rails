require 'test_helper'

class ControllerMethodsTestController < ActionController::Base
  include SimpleJsonApi::Rails::ControllerMethods

  def self.controller_path
    'test'
  end

  def simple_render
    render jsonapi: test_object, serializer: test_serializer
  end
end

describe ControllerMethodsTestController do
  let(:jsonapi_mime_type) { 'application/vnd.api+json' }
  let(:json_mime_type) { 'application/json' }
  let(:unsupported_mime_type) { 'text/html' }

  before do
    Rails.application.routes.append do
      get 'simple_render' => 'test#simple_render'
    end
    Rails.application.routes_reloader.reload!
  end

  describe 'with no HTTP_ACCEPT/Accept header' do
    before do
      @request.headers.instance_exec { @env.delete('HTTP_ACCEPT') }
    end

    it 'returns Not Acceptable' do
      get :simple_render
      must_respond_with 406
    end
  end

  describe 'without JSON API mime type in Accept header' do
    before do
      @request.headers['Accept'] = json_mime_type
    end

    it 'returns Not Acceptable' do
      get :simple_render
      must_respond_with 406
    end
  end

  describe 'with JSON API mime type in Accept header' do
    before do
      @request.headers['Accept'] = jsonapi_mime_type
    end

    it 'returns OK' do
      get :simple_render
      must_respond_with 200
    end

    describe 'with unsupported Content-Type header' do
      before do
        @request.headers['Content-Type'] = unsupported_mime_type
      end

      it 'returns Unsupported Media Type' do
        get :simple_render
        must_respond_with 415
      end
    end
  end

  describe 'with extentions' do
    before do
      @request.headers['Accept'] = "#{jsonapi_mime_type};q=0.8;ext=supportme"
    end

    it 'returns Not Acceptable' do
      get :simple_render
      must_respond_with 406
    end
  end
end
