require 'spec_helper'

RSpec.describe 'Rails 6 API' do
  it 'it provides Rails controller api' do
    map =
      use_workspace './spec/rails6' do |root|
        root.write_file 'app/controllers/things_controller.rb', <<~EOS
          class ThingsController < ActionController::Base
            res
            def index
              re
            end
          end
        EOS
      end

    filename = './app/controllers/things_controller.rb'
    expect(completion_at(filename, [1, 4], map)).to include('rescue_from')

    expect(completion_at(filename, [3, 5], map)).to include(
      'respond_to',
      'redirect_to',
      'response',
      'request',
      'render'
    )
  end

  it 'can auto-complete inside routes' do
    map =
      use_workspace './spec/rails6' do |root|
        root.write_file 'config/routes.rb', <<~EOS
        Rails.application.routes.draw do
          res
          resource :things do
            res
          end
        end
      EOS
      end

    filename = './config/routes.rb'
    expect(completion_at(filename, [1, 5], map)).to include('resources')
    expect(completion_at(filename, [3, 7], map)).to include('resources')
  end

  it 'can auto-complete inside mailers' do
    map =
      use_workspace './spec/rails6' do |root|
        root.write_file 'app/mailers/test_mailer.rb', <<~EOS
        class TestMailer < ActionMailer::Base
          defa
          def welcome_email
            ma
          end
        end
      EOS
      end

    filename = './app/mailers/test_mailer.rb'
    expect(completion_at(filename, [1, 6], map)).to include('default')
    expect(completion_at(filename, [3, 6], map)).to include('mail')
  end

  it 'can auto-complete inside migrations' do
    map =
      use_workspace './spec/rails6' do |root|
        root.write_file 'db/migrate/20130502114652_create_things.rb', <<~EOS
        class CreateThings < ActiveRecord::Migration[5.2]
          def self.up
            crea
          end

          def change
            crea
            create_table :things do |t|
              t.col
            end
            change_table :things do |t|
              t.col
            end
            create_join_table :things do |t|
              t.col
            end
          end
        end
      EOS
      end

    filename = './db/migrate/20130502114652_create_things.rb'
    expect(completion_at(filename, [2, 7], map)).to include('create_table')
    expect(completion_at(filename, [6, 7], map)).to include('create_table')
    expect(completion_at(filename, [8, 10], map)).to include('column')
    expect(completion_at(filename, [11, 10], map)).to include('column')
    expect(completion_at(filename, [14, 10], map)).to include('column')
  end

  it 'provides completions for ActiveJob::Base' do
    map = use_workspace './spec/rails6'

    assert_matches_definitions(map, 'ActiveJob::Base', 'rails6/activejob')
  end

  it 'provides completions for ActionDispatch::Routing::Mapper' do
    map = use_workspace './spec/rails6'

    assert_matches_definitions(
      map,
      'ActionDispatch::Routing::Mapper',
      'rails6/routes'
    )
  end

  it 'provides completions for ActiveRecord::Base' do
    map = use_workspace './spec/rails6'

    assert_matches_definitions(map, 'ActiveRecord::Base', 'rails6/activerecord')
  end

  it 'provides completions for ActionController::Base' do
    map = use_workspace './spec/rails6'
    assert_matches_definitions(
      map,
      'ActionController::Base',
      'rails6/actioncontroller'
    )
  end

  it 'auto-completes ActiveSupport core extensions' do
    map = use_workspace './spec/rails6'

    Dir
      .glob('spec/definitions/rails6/core/*.yml')
      .each do |path|
        name = File.basename(path).split('.').first

        assert_matches_definitions(map, name, "rails6/core/#{name}")
      end
  end
end
