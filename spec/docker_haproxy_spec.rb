require 'dockerspec/serverspec'
$stdout.sync = true

image = 'haproxy'
tag = 'latest'
haproxyconf = 'haproxy.conf'

describe "image #{image}:#{tag}"  do

  ## Preparation steps
  before(:all) do
    command = ""
    if (tag)
      testimage = "#{image}:#{tag}"
    else
      testimage = "#{image}"
    end
    testhaproxyconf = ""
    if (haproxyconf)
      # do not map file if file does not exist or is a directory
      absPath = "#{Dir.pwd}/#{haproxyconf}"
      if (File.file?(absPath))
        testhaproxyconf = "-v #{absPath}:/usr/local/etc/haproxy/haproxy.cfg"
      end
    end
    # not supressing printing the container id for later reference (e.g. cleanup)
    print "container_id spawned: "
    system("docker run --rm -d --name #{image} #{testhaproxyconf} #{image}:#{tag} sleep 600" )
    @container = Docker::Container.get("#{image}")
      set :backend, :docker
      set :docker_container, @container.id
  end

  ## Testing the image
  describe docker_build(id: "#{image}:#{tag}") do
    its(:cmd) { should eq ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"] }
  end

  ## Testing the container
  describe "run image #{image}:#{tag}"  do
    describe file ('/usr/local/etc/haproxy/haproxy.cfg') do
      it { should exist }
    end
    describe file ('/usr/local/sbin/haproxy') do
      it { should exist }
      it { should be_file }
      it { should be_executable }
      it { should be_owned_by 'root' }
    end
  end

  ## Cleaning up the mass
  after(:all) do
    system ("docker rm -f #{image} > /dev/null")
  end
end



