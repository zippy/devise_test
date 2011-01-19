def export_table(table_name,where='true',id_field='id')
  File.open("#{RAILS_ROOT}/db/#{table_name}.yml", 'w') do |file|
    data = ActiveRecord::Base.connection.select_all("SELECT * FROM %s where %s" % [table_name,where])
    file.write data.inject({}) { |hash, record|
      id = record[id_field]
      hash["#{table_name}_#{id}"] = record
      hash
    }.to_yaml
  end
end
  
namespace :db do
  desc 'Create YAML test fixtures from data in an existing database.  
  Defaults to development database. Set RAILS_ENV to override.'

  task :extract_fixtures => :environment do
    export_table('users',"id in (437)",'user_name')#129,436,714
#    export_table('form_instances',"id in (34970, 6525, 33868, 14824, 15855, 16295, 16985, 17929, 17938, 18241, 18524, 19224, 20067, 20450, 20644, 20645, 21495, 22287, 22288, 22668, 22826, 22827, 23038, 23222, 23442, 23492, 23507, 23508, 23509, 23741, 24271, 24294, 24317, 25281, 25447, 26193, 26194, 26540, 26677, 26739, 26742, 26743, 27177, 28013, 28014, 28015, 28129, 28130, 28462, 28466, 28470, 28621, 28622, 28623, 28721, 28722, 28723, 29007, 29288, 29345, 29346, 29404, 29490, 29701, 29773, 29774, 29866, 29898, 30382, 30383, 30611, 30612, 30837, 31380, 31381, 31466, 31783, 32698, 33193, 33703, 33947, 33948, 34181, 34232, 34397, 34405, 34691, 35045, 35046, 35048, 35066, 35067, 35183, 35362, 35661, 35697, 35979, 35980, 35982, 36186, 36187, 36384, 36388, 36390, 36391, 36392, 36559, 36629, 36768, 37647, 38000, 38892, 38998, 39443, 39488, 40043, 40068, 40079, 40080, 40549, 40760, 40802, 40980, 41219, 41503, 41543, 41544, 41582, 41732)")
#    export_table('field_instances',"field_id in ('H_ConsentRecordedDate',  'H_SubmittedDate', 'H_FormFilled', 'H_SubmittedBy', 'H_AdminNotes',  'H_ReviewedBy', 'H_Ccode', 'H_Pid', 'H_Source', 'H_ClaimedBy', 'H_CreatedBy', 'H_Form', 'H_Mid1', 'H_Mid2', 'H_Mid3','Book_LogPostmarkDate', 'Book_ConsentPostmarkDate', 'Book_EstimatedDueDate', 'Book_ConsentFormVersion', 'Book_BookingDate', 'Book_ConsentFormOKToContact', 'Book_ConsentHashCode', 'Book_ConsentSigned', 'Book_PrivateNotes', 'Book_MonthConsentSent', 'Book_ConsentRefusedHashCode') and form_instance_id in (34970, 6525, 33868, 14824, 15855, 16295, 16985, 17929, 17938, 18241, 18524, 19224, 20067, 20450, 20644, 20645, 21495, 22287, 22288, 22668, 22826, 22827, 23038, 23222, 23442, 23492, 23507, 23508, 23509, 23741, 24271, 24294, 24317, 25281, 25447, 26193, 26194, 26540, 26677, 26739, 26742, 26743, 27177, 28013, 28014, 28015, 28129, 28130, 28462, 28466, 28470, 28621, 28622, 28623, 28721, 28722, 28723, 29007, 29288, 29345, 29346, 29404, 29490, 29701, 29773, 29774, 29866, 29898, 30382, 30383, 30611, 30612, 30837, 31380, 31381, 31466, 31783, 32698, 33193, 33703, 33947, 33948, 34181, 34232, 34397, 34405, 34691, 35045, 35046, 35048, 35066, 35067, 35183, 35362, 35661, 35697, 35979, 35980, 35982, 36186, 36187, 36384, 36388, 36390, 36391, 36392, 36559, 36629, 36768, 37647, 38000, 38892, 38998, 39443, 39488, 40043, 40068, 40079, 40080, 40549, 40760, 40802, 40980, 41219, 41503, 41543, 41544, 41582, 41732)")
  end
end

