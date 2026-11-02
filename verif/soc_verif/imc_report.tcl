# Cadence IMC Batch Script for SentinelSOC Code Coverage Reporting
# Loads coverage database from cov_work and generates detailed text & HTML summaries.

load -run cov_work/scope/test_integrated

# Set metrics: Block/Line, Branch, Expression, Toggle, FSM
report_metrics -detail -metrics "block expr branch toggle fsm"

# Generate comprehensive text report
report_summary -out cov_summary.txt -metrics "block expr branch toggle fsm"
report_detail  -out cov_detail.txt  -metrics "block expr branch toggle fsm"

# Generate HTML report
report_html -out cov_html -metrics "block expr branch toggle fsm"

puts "================================================================="
puts " Cadence IMC Coverage Reports successfully generated in cov_html/ "
puts " Check cov_summary.txt for line, toggle, branch, FSM scores       "
puts "================================================================="
exit
