require 'fileutils'
module FileHelper
  def create_directory name
    Dir::mkdir(name) unless FileTest::directory?(name)
  end

  def delete_directory name
    FileUtils.rm_rf(name)
  end
end
