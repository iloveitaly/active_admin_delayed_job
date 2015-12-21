$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "active_admin_delayed_job"
  s.version     = "1.0.3"
  s.authors     = ["Michael Bianco", "Darren Rush"]
  s.email       = ["mike@cliffsidemedia.com"]
  s.homepage    = "http://github.com/iloveitaly/active_admin_delayed_job"
  s.summary     = "A plug-and-play controller that lets you monitor and retry jobs easily."
  s.description = "View all, running, failed, and queued jobs.  Retry failed jobs."

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_dependency 'activeadmin'
  s.add_dependency 'delayed_job_active_record'
end
