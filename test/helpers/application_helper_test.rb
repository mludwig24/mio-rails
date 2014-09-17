require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
	test "slug-formatting" do
		assert "".slug == "", 
			"Should do nothing with an empty string."
		assert "this and that".slug == "this-and-that",
			"Should turn spaces into dashes."
		assert "   this   ".slug == "this",
			"Should trim spaces."
		assert "   this that   ".slug == "this-that",
			"Should trim spaces, but not between words."
		assert "this && that".slug == "this--that",
			"Should remove excess characters, and add extra dashes."
	end
end
