# model_yaml.rb
namespace :model_locale do
	desc "Output YAML locale for models."
	task :yaml => :environment do
		attributes = class_breakdown()
		puts insert_into_locale(attributes).to_yaml
	end
	task :yaml_missing => :environment do
		attributes = class_breakdown()
		scope = "activerecord.attributes"
		attributes.keys.each do |model|
			attributes[model].keep_if do |key,value|
				begin
					I18n.t("#{model}.#{key}", :scope => scope,
						:raise => true)
					false
				rescue
					true
				end
			end
		end
		puts insert_into_locale(attributes).to_yaml
	end
	private
	def insert_into_locale(attributes, locale=I18n.default_locale.to_s)
		return {locale => 
				{"activerecord" => {
					"attributes" => attributes,
				},
			},
		}
	end
	def class_breakdown
		attributes = Hash.new()
		Rails.application.eager_load!
		model_classes = ActiveRecord::Base.descendants
		model_classes.each do |klass|
			unless klass.to_s.start_with?("ActiveRecord")
				key = klass.to_s.downcase
				attributes[key] = Hash.new()
				klass.columns.each do |column|
					unless column.name == "id"
						attributes[key][column.name] = column.name.titleize
					end
				end
			end
		end
		return attributes
	end
end