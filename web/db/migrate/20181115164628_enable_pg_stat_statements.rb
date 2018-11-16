class EnablePgStatStatements < ActiveRecord::Migration[5.2]
  enable_extension "pg_stat_statements"
end
