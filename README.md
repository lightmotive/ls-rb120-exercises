# Launch School - RB120 Course - Exercises

Object Oriented Programming

## Dependencies

### ruby-common

Clone *[ruby-common](https://github.com/lightmotive/ruby-common.git)* to this project's parent directory.

- The ruby-common project's files will eventually be converted and published as gems to avoid "dependency hell".

## Helpful shell scripts

- Create Ruby exercise files with default content:

  ```bash
  file_names=(name1 name2)
  for name in $file_names; do touch "$name.rb"; printf '# frozen_string_literal: true\n' > "$name.rb"; done
  ```
  
- Set frozen_string_literal comment to all Ruby files in current directory:
  - `for f in ./*.rb; do printf '# frozen_string_literal: true\n' > "$f"; done`
  - For advanced functionality, use find: `find ./*.rb -maxdepth 0 -exec bash -c "printf '# frozen_string_literal: true\n' > '{}'" ';'`