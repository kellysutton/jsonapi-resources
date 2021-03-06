require File.expand_path('../../../test_helper', __FILE__)
require File.expand_path('../../../fixtures/active_record', __FILE__)

class RequestTest < ActionDispatch::IntegrationTest

  def test_get
    get '/posts'
    assert_equal 200, status
  end

  def test_get_underscored_key
    JSONAPI.configuration.json_key_format = :underscored_key
    get '/iso_currencies'
    assert_equal 200, status
    assert_equal 3, json_response['iso_currencies'].size
  end

  def test_get_underscored_key_filtered
    JSONAPI.configuration.json_key_format = :underscored_key
    get '/iso_currencies?country_name=Canada'
    assert_equal 200, status
    assert_equal 1, json_response['iso_currencies'].size
    assert_equal 'Canada', json_response['iso_currencies'][0]['country_name']
  end

  def test_get_camelized_key_filtered
    JSONAPI.configuration.json_key_format = :camelized_key
    get '/iso_currencies?countryName=Canada'
    assert_equal 200, status
    assert_equal 1, json_response['isoCurrencies'].size
    assert_equal 'Canada', json_response['isoCurrencies'][0]['countryName']
  end

  def test_get_camelized_route_and_key_filtered
    get '/api/v4/isoCurrencies?countryName=Canada'
    assert_equal 200, status
    assert_equal 1, json_response['isoCurrencies'].size
    assert_equal 'Canada', json_response['isoCurrencies'][0]['countryName']
  end

  def test_get_camelized_route_and_links
    JSONAPI.configuration.json_key_format = :camelized_key
    get '/api/v4/expenseEntries/1/links/isoCurrency'
    assert_equal 200, status
    assert_equal 'USD', json_response['isoCurrency']
  end

  def test_put_single_without_content_type
    put '/posts/3',
        {
          'posts' => {
            'id' => '3',
            'title' => 'A great new Post',
            'links' => {
              'tags' => [3, 4]
            }
          }
        }.to_json, "CONTENT_TYPE" => "application/json"

    assert_equal 415, status
  end

  def test_put_single
    put '/posts/3',
        {
          'posts' => {
            'id' => '3',
            'title' => 'A great new Post',
            'links' => {
              'tags' => [3, 4]
            }
          }
        }.to_json, "CONTENT_TYPE" => JSONAPI::MEDIA_TYPE

    assert_equal 200, status
  end

  def test_post_single_without_content_type
    post '/posts',
      {
        'posts' => {
          'title' => 'A great new Post',
          'links' => {
            'tags' => [3, 4]
          }
        }
      }.to_json, "CONTENT_TYPE" => "application/json"

    assert_equal 415, status
  end

  def test_post_single
    post '/posts',
      {
        'posts' => {
          'title' => 'A great new Post',
          'body' => 'JSONAPIResources is the greatest thing since unsliced bread.',
          'links' => {
            'author' => '3'
          }
        }
      }.to_json, "CONTENT_TYPE" => JSONAPI::MEDIA_TYPE

    assert_equal 201, status
  end

  def test_create_association_without_content_type
    ruby = Section.find_by(name: 'ruby')
    put '/posts/3/links/section', { 'sections' => ruby.id.to_s }.to_json

    assert_equal 415, status
  end

  def test_create_association
    ruby = Section.find_by(name: 'ruby')
    put '/posts/3/links/section', { 'sections' => ruby.id.to_s }.to_json, "CONTENT_TYPE" => JSONAPI::MEDIA_TYPE

    assert_equal 204, status
  end

  def test_index_content_type
    get '/posts'
    assert_match JSONAPI::MEDIA_TYPE, headers['Content-Type']
  end

  def test_get_content_type
    get '/posts/3'
    assert_match JSONAPI::MEDIA_TYPE, headers['Content-Type']
  end

  def test_put_content_type
    put '/posts/3',
        {
          'posts' => {
            'id' => '3',
            'title' => 'A great new Post',
            'links' => {
              'tags' => [3, 4]
            }
          }
        }.to_json, "CONTENT_TYPE" => JSONAPI::MEDIA_TYPE

    assert_match JSONAPI::MEDIA_TYPE, headers['Content-Type']
  end

  def test_post_correct_content_type
    post '/posts',
      {
       'posts' => {
         'title' => 'A great new Post',
         'links' => {
           'author' => '3'
         }
       }
     }.to_json, "CONTENT_TYPE" => JSONAPI::MEDIA_TYPE

    assert_match JSONAPI::MEDIA_TYPE, headers['Content-Type']
  end

  def test_destroy_single
    delete '/posts/7'
    assert_equal 204, status
    assert_nil headers['Content-Type']
  end

  def test_destroy_multiple
    delete '/posts/8,9'
    assert_equal 204, status
  end
end
