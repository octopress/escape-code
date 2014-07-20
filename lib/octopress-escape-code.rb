require "octopress-escape-code/version"
require 'jekyll-page-hooks'

module Jekyll
  class EscapeCode < PageHooks
    def pre_render(page)
      site_config = page.site.config['escape_code']
      site_config = true if site_config.nil?

      page_config = page.data['escape_code']
      page_config = site_config if page_config.nil?

      enabled = page_config

      if enabled
        page.content = Octopress::EscapeCode.escape(page.content, page.ext)
      end
    end
  end
end

module Octopress
  module EscapeCode
    def self.escape(content, ext)
      ext = ext.downcase
      content.encode!("UTF-8")
      md_ext = %w{.markdown .mdown .mkdn .md .mkd .mdwn .mdtxt .mdtext}

      # Escape codefenced codeblocks
      content = content.gsub /^(`{3}.+?`{3})/m do
        "{% raw %}\n#{$1}\n{% endraw %}"
      end

      # Escape markdown style code blocks
      if md_ext.include?(ext)

        # Escape four space indented code blocks
        content = content.gsub /^(\s{4}.+?)\n($|[^\s{4}])/m do
          "{% raw %}\n#{$1}\n{% endraw %}\n#{$2}"
        end
        
        # Escape tab indented code blocks
        content = content.gsub /^(\t.+?)\n($|[^\t])/m do
          "{% raw %}\n#{$1}\n{% endraw %}\n#{$2}"
        end

        # Escape in-line code backticks
        content = content.gsub /(`{1,2}[^`\n]+?`{1,2})/ do
          "{% raw %}#{$1}{% endraw %}"
        end

      end

      # Escape codeblock tag contents
      content = content.gsub /^({%\s*codeblock.+?%})(.+?)({%\s*endcodeblock\s*%})/m do
        "#{$1}{% raw %}#{$2}{% endraw %}#{$3}"
      end

      # Escape highlight tag contents
      content = content.gsub /^({%\s*highlight.+?%})(.+?)({%\s*endhighlight\s*%})/m do
        "#{$1}{% raw %}#{$2}{% endraw %}#{$3}"
      end

      content
    end
  end
end
