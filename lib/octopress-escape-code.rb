require "octopress-escape-code/version"
require 'octopress-hooks'

module Octopress
  module EscapeCode

    class EscapePage < Octopress::Hooks::Page
      def pre_render(page)
        if Octopress::EscapeCode.escape_enabled?(page)
          page.content = Octopress::EscapeCode.escape(page.content, page.ext)
        end
      end
    end

    class EscapePost < Octopress::Hooks::Post
      def pre_render(page)
        if Octopress::EscapeCode.escape_enabled?(page)
          page.content = Octopress::EscapeCode.escape(page.content, page.ext)
        end
      end
    end

    def self.escape_enabled?(page)
      site_config = page.site.config['escape_code']
      site_config = true if site_config.nil?

      page_config = page.data['escape_code']
      page_config = site_config if page_config.nil?

      enabled = page_config
    end

    def self.escape(content, ext)
      ext = ext.downcase
      content.encode!("UTF-8")
      md_ext = %w{.markdown .mdown .mkdn .md .mkd .mdwn .mdtxt .mdtext}

      # Escape markdown style code blocks
      if md_ext.include?(ext)

        # Escape four space indented code blocks
        content = content.gsub /^( {4}[^\n].+?)\n($|\S)/m do
          "{% raw %}\n#{$1}\n{% endraw %}\n#{$2}"
        end
        
        # Escape tab indented code blocks
        content = content.gsub /^(\t[^\n].+?)\n($|\S)/m do
          "{% raw %}\n#{$1}\n{% endraw %}\n#{$2}"
        end

        # Escape in-line code backticks
        content = content.gsub /(`[^`\n]+?`)/ do
          "{% raw %}#{$1}{% endraw %}"
        end

        # Escape in-line code double backticks
        content = content.gsub /(``[^\n]+?``)/ do
          "{% raw %}#{$1}{% endraw %}"
        end

      end

      # Escape codefenced codeblocks
      content = content.gsub /^(`{3}.+?`{3})/m do
        
        # Replace any raw/endraw tags inside of codefence block
        # as some of the regex above may have escaped contents
        # of the codefence block
        #
        code = $1.gsub(/{% raw %}(\n)?/, '').gsub(/(\n)?{% endraw %}/, '') 

        # Wrap codefence content in raw tags
        "{% raw %}\n#{code}\n{% endraw %}"
      end

      # Escape codeblock tag contents
      content = content.gsub /^({%\s*codeblock.+?%})(.+?){%\s*endcodeblock\s*%}/m do
        "#{$1}{% raw %}#{$2.gsub /{% (end)?raw %}\n/, ''}{% endraw %}{% endcodeblock %}"
      end

      # Escape highlight tag contents
      content = content.gsub /^({%\s*highlight.+?%})(.+?){%\s*endhighlight\s*%}/m do
        "#{$1}{% raw %}#{$2.gsub(/{% (end)?raw %}\n/, '')}{% endraw %}{% endhighlight %}"
      end

      content
    end
  end
end
