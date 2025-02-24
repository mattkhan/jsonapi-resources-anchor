require "rails_helper"

RSpec.describe Anchor::TypeInferable do
  describe "super spying" do
    subject(:klass) do
      Class.new(subklass) do
        include Anchor::TypeInferable
      end
    end

    let(:subklass) { Class.new }

    before do
      allow(subklass).to receive(:method_added).and_call_original
    end

    it "calls super with correct args" do
      klass.class_eval do
        def one = 1
      end

      expect(subklass).to have_received(:method_added).with(:one)
      expect(klass.anchor_method_added_count).to eql({ one: 1 })
    end
  end

  describe "JSONAPI::Resource integrations" do
    around { |example| stub_jsonapi_resource_subclass("UserResource", &example) }

    describe ".anchor_schema_name" do
      subject(:anchor_schema_name) { UserResource.anchor_schema_name }

      context "with provided schema name" do
        it "uses the provided schema name" do
          UserResource.class_eval do
            include Anchor::TypeInferable

            anchor_schema_name "Provided__User"
          end

          expect(anchor_schema_name).to eql("Provided__User")
        end
      end

      context "without schema name" do
        around { |example| stub_jsonapi_resource_subclass("TestResources", &example) }

        it "uses the default schema name" do
          UserResource.class_eval do
            include Anchor::TypeInferable
          end

          expect(anchor_schema_name).to eql("User")
        end

        context "without use_type_as_schema_name config enabled" do
          before do
            allow(Anchor.config).to receive(:use_type_as_schema_name).and_return(false)
          end

          it "uses the default schema name" do
            TestResources.class_eval do
              include Anchor::TypeInferable
            end

            expect(TestResources.anchor_schema_name).to eql("TestResources")
          end
        end

        context "with use_type_as_schema_name config enabled" do
          before do
            allow(Anchor.config).to receive(:use_type_as_schema_name).and_return(true)
          end

          it "uses classified _type" do
            TestResources.class_eval do
              include Anchor::TypeInferable
            end

            expect(TestResources.anchor_schema_name).to eql("TestResource")
          end
        end
      end
    end

    describe ".method_added" do
      subject(:anchor_method_added_count) { UserResource.anchor_method_added_count }

      it "accurately counts method added" do
        UserResource.class_eval do
          include Anchor::TypeInferable

          attribute :name
          attribute :role
          attribute :three

          def role = "2"
          def three = "2"
          def three = "3"
        end

        expect(anchor_method_added_count).to match(hash_including(
          name: 1,
          role: 2,
          three: 3,
        ))
      end
    end
  end
end
