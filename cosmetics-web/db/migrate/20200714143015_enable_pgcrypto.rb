class EnablePgcrypto < ActiveRecord::Migration[5.2]
  def change

    safety_assured do
      enable_extension "pgcrypto"
    end
  end
end
