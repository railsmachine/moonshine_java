module Moonshine
  module Java

    def self.included(manifest)
      manifest.class_eval do
        extend ClassMethods
        configure :java => { :package => 'sun-java6-bin' }
      end
    end

    module ClassMethods
      def java_template_dir
        @java_template_dir ||= Pathname.new(__FILE__).join('..', '..', '..', 'templates').expand_path.relative_path_from(Pathname.pwd)
      end
    end

    def java(options = {})
      java_package = (options[:package] || configuration[:java][:package])

      java_alternative = case java_package
                         when "sun-java6-bin" then "java-6-sun"
                         else java_package
                         end

      package java_package,
        :ensure  => :installed,
        :alias   => 'java',
        :require => [ exec('noninteractive-dpkg'), exec('debconf-set-java-selections') ]

      exec 'debconf-set-selections < /etc/java-debconf-set-selections',
        :alias   => 'debconf-set-java-selections',
        :require => file('/etc/java-debconf-set-selections')

      exec 'dpkg-reconfigure debconf --frontend=noninteractive',
        :alias => 'noninteractive-dpkg'

      file '/etc/java-debconf-set-selections',
        :content => template(java_template_dir.join('java-debconf-set-selections.erb'), binding),
        :notify  => exec('debconf-set-java-selections')

      exec "update-java-alternatives -s #{java_alternative} || true",
        :require => package('java'),
        :alias   => 'update-java-alternatives'
      
      recipe :canonical_source
    end

    def canonical_source
      append_if_no_such_line "deb http://archive.canonical.com/ubuntu lucid partner",
        "/etc/apt/sources.list",
        :before => exec('apt-get update')
    end

    private
    def append_if_no_such_line(line, file, options = {})
      hash = {
        :command => "/bin/echo '#{line}' >> #{file}", 
        :unless  => "/bin/grep -Fxqe '#{line}' #{file}" 
      }
      hash.merge!(options)

      exec "add #{line} to #{file}",
        hash
    end
  end
end
