require "rails_helper"

RSpec.describe Anchor::Annotatable do
  describe 'super spying' do
    let(:subklass) do
      Class.new do
        class << self
          def attribute(attribute_name, options = {})
          end

          def relationship(*attrs)
          end
        end
      end
    end

    describe ".attribute" do
      before do
        allow(subklass).to receive(:attribute).and_call_original
      end

      context 'without annotations' do
        it 'sends the correct args to super' do
          Class.new(subklass) do
            include Anchor::Annotatable

            attribute :name
            attribute :role, delegate: :computed_role, format: :some_format, description: "Test"
          end

          expect(subklass).to have_received(:attribute).with(:name, {}).once
          expect(subklass).to have_received(:attribute).with(:role, {
            delegate: :computed_role,
            format: :some_format,
            description: "Test"
          }).once
        end
      end

      context 'with annotations' do
        it 'sends the correct args to super' do
          Class.new(subklass) do
            include Anchor::Annotatable

            attribute :name, Anchor::Types::String
            attribute :role, Anchor::Types::String, delegate: :computed_role, format: :some_format, description: "Test"
            attribute :another_one, nil, delegate: :another, format: :another_format, description: "Another"
          end

          expect(subklass).to have_received(:attribute).with(:name, {}).once

          expect(subklass).to have_received(:attribute).with(:role, {
            delegate: :computed_role,
            format: :some_format,
            description: "Test"
          }).once

          expect(subklass).to have_received(:attribute).with(:another_one, {
            delegate: :another,
            format: :another_format,
            description: "Another"
          }).once
        end
      end
    end

    describe '.relationship' do
      before do
        allow(subklass).to receive(:relationship)
      end

      context 'without annotations' do
        it 'sends the correct args to super' do
          Class.new(subklass) do
            include Anchor::Annotatable

            relationship :account, to: :one
            relationship :comments, to: :many, acts_as_set: true
          end

          expect(subklass).to have_received(:relationship).with(:account, { to: :one }).once
          expect(subklass).to have_received(:relationship).with(:comments, {
            to: :many,
            acts_as_set: true,
          }).once
        end
      end

      context 'with annotations' do
        it 'sends the correct args to super' do
          Class.new(subklass) do
            include Anchor::Annotatable

            relationship :account, Anchor::Types::String, to: :one
            relationship :comments, Anchor::Types::String, to: :many, acts_as_set: true, exclude_links: :default, description: "Test"
            relationship :another_one, nil, to: :many, description: "Another", acts_as_set: false, exclude_links: :default
          end

          expect(subklass).to have_received(:relationship).with(:account, { to: :one }).once

          expect(subklass).to have_received(:relationship).with(:comments, {
            to: :many,
            acts_as_set: true,
            exclude_links: :default,
            description: "Test",
          }).once

          expect(subklass).to have_received(:relationship).with(:another_one, {
            to: :many,
            acts_as_set: false,
            exclude_links: :default,
            description: "Another",
          }).once
        end
      end
    end
  end

  describe 'JSONAPI::Resource integrations' do
    describe '.attribute' do
      around { |example| stub_jsonapi_resource_subclass('UserResource', &example) }

      context 'without anchor annotations' do
        it 'does not store annotations' do
          UserResource.instance_eval do
            include Anchor::Annotatable

            attribute :name
            attribute :role, delegate: :computed_role, format: :some_format
          end

          expect(UserResource.anchor_attributes).to eql({})
          expect(UserResource.anchor_attributes_descriptions).to eql({})

          expect(UserResource.fields).to contain_exactly(:id, :name, :role)
          expect(UserResource._attributes).to match({
            id: anything,
            name: {},
            role: { delegate: :computed_role, format: :some_format }
          })
        end
      end

      context 'with anchor annotations' do
        it 'stores annotations' do
          login_count_description = "Number of successful logins."

          UserResource.class_eval do
            include Anchor::Annotatable

            attribute :name, Anchor::Types::String
            attribute :login_count, Anchor::Types::Integer, format: :some_format, description: login_count_description
          end

          expect(UserResource.anchor_attributes).to eql({ name: Anchor::Types::String, login_count: Anchor::Types::Integer })
          expect(UserResource.anchor_attributes_descriptions).to eql({ login_count: login_count_description })

          expect(UserResource.fields).to contain_exactly(:id, :name, :login_count)
          expect(UserResource._attributes).to match({
            id: anything,
            name: {},
            login_count: { format: :some_format, description: login_count_description }
          })
        end
      end
    end

    describe '.relationship' do
      around { |example| stub_jsonapi_resource_subclass('UserResource', &example) }

      context 'without anchor annotations' do
        it 'does not store annotations' do
          UserResource.class_eval do
            include Anchor::Annotatable

            relationship :user, to: :one
            relationship :comments, to: :many, acts_as_set: true
          end

          expect(UserResource.anchor_relationships).to eql({})
          expect(UserResource.anchor_relationships_descriptions).to eql({})

          expect(UserResource.fields).to contain_exactly(:id, :user, :comments)
          expect(UserResource._relationships.map(&:first)).to contain_exactly(:user, :comments)
          expect(UserResource._relationships.map(&:second).map(&:resource_klass)).to contain_exactly(UserResource, CommentResource)
        end
      end

      context 'with anchor annotations' do
        it 'stores annotations' do
          UserResource.class_eval do
            include Anchor::Annotatable

            relationship :user, Anchor::Types::Relationship.new(resource: UserResource, null: true), to: :one
            relationship :comments, Anchor::Types::Relationship.new(resource: CommentResource), to: :many, acts_as_set: true, exclude_links: :default, description: "Comments"
            relationship :exhaustives, nil, to: :many, description: "Exhaustives", acts_as_set: false, exclude_links: :default
          end

          expect(UserResource.anchor_relationships).to eql({
            user: Anchor::Types::Relationship.new(resource: UserResource, null: true),
            comments: Anchor::Types::Relationship.new(resource: CommentResource),
          })
          expect(UserResource.anchor_relationships_descriptions).to eql({
            exhaustives: "Exhaustives",
            comments: "Comments",
          })

          expect(UserResource.fields).to contain_exactly(:id, :user, :comments, :exhaustives)
          expect(UserResource._relationships.map(&:first)).to contain_exactly(:user, :comments, :exhaustives)
          expect(UserResource._relationships.map(&:second).map(&:resource_klass)).to contain_exactly(UserResource, CommentResource, ExhaustiveResource)
        end
      end
    end
  end
end
