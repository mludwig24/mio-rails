require 'test_helper'

class PhoneHelperTest < ActionView::TestCase
	test "raw_phone-stripping" do
		assert "(928) . 555-1212".raw_phone == "9285551212",
			"Should remove excess characters."
		assert "(928)-PHONENU".raw_phone == "928",
			"Should remove non-digit characters."
		assert "1 (928)-555.1212".raw_phone == "9285551212",
			"Should remove preceiding one."
	end
	test "phone_formatting" do
		assert "9285551212".phone == "928-555-1212",
			"Should add dashes."
		assert "928.555.1212".phone == "928-555-1212",
			"Should convert dots to dashes."
		assert "(928).555 1212".phone == "928-555-1212",
			"Should remove excess characters."
		assert "928-555-1212".phone == "928-555-1212",
			"Should leave dashes alone."
		assert "+01 55 928-555-1212".phone == "01559285551212"
			"Should return raw phone if too long."
	end
	test "phone?_validity" do
		assert "9285551212".phone?,
			"Should accept valid phone numbers."
		assert "928.555-1212".phone?,
			"Should strip out non-numeric characters."
		assert "1 928 555 1212".phone?
			"Should work with an area code."
		assert "928-PHON-ENU".phone? == false,
			"Should not accept letters in phone numbers."
	end
end