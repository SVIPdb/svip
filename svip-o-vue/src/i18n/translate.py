import os, re
from bs4 import BeautifulSoup


BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
I18N_DIR = os.path.join(BASE_DIR, 'i18n')
LOCALES_DIR = os.path.join(BASE_DIR, 'locales')

def add_to_json(newStr):
  json_doc = open(f"{LOCALES_DIR}/en.json", "r+")
  json_lines = json_doc.readlines()
  for line in json_lines:
    substrings = line.split('"')
    if len(substrings) > 1:
      if newStr == substrings[1]:
        print('String was already stored.')
        break
  else:
    commaNeeded = json_lines[-2]
    del json_lines[-2]
    json_lines.insert(-1, f"{commaNeeded[:-1]},\n")
    json_lines.insert(-1, f'  "{newStr}": "{newStr}"\n')
    content = "".join(json_lines)
    json_doc.seek(0)
    json_doc.truncate()
    json_doc.write(content)
    json_doc.close()
    print('Added to en.json')


def substrings_outside_of_curly_braces(string):
  strings_of_interest = []
  gross_substrings = re.split("{{(.+?)}}", string)
  # get rid of odd indexes values (those found between curly braces)
  for i in range(len(gross_substrings)):
    if i % 2 == 0:
      strings_of_interest.append(gross_substrings[i])
  return strings_of_interest


def replace_in_file(path_of_file_to_translate, html_lines, element, original_string):
  new_string = '{{ $t("%s")}}' % (original_string)

  for idx, line in enumerate(html_lines):
    patterns_in_line = len(re.findall(re.escape(original_string), line))
    for i in range(patterns_in_line):

      temp_lines = html_lines
      original_line = html_lines[idx]
      new_line = original_line.replace(original_string, new_string, i+1).replace(new_string, original_string, i)
      temp_lines[idx] = new_line

      temp_doc = open(f"{I18N_DIR}/temp.html", "r+")
      temp_doc.write("".join(temp_lines))
      temp_doc.close()
      
      temp_doc = open(f"{I18N_DIR}/temp.html", "r+")
      temp_soup = BeautifulSoup(temp_doc, 'html.parser')
      temp_text = temp_soup.find_all()[0].text
      temp_doc.close()
      
      if substrings_outside_of_curly_braces(temp_text) == substrings_outside_of_curly_braces(element.text):
        # the wrong segment has been replaced because the innerHTML text is the same. Try replacing next pattern
        pass
      else:
        html_doc = open(path_of_file_to_translate, "r+")
        html_doc.write("".join(temp_lines))
        html_doc.close()
        print('Text is replaced.')
        return True
  print("!!! UNEXPECTED: Failed to replace string in component !!!")


def get_strings(path_of_file_to_translate, soup, html_lines):
  templateElement = soup.find_all()[0]
  innerHTML = templateElement.text
  # check presence of letters in substring:
  if bool(re.search('[a-zA-Z]', innerHTML)):
    strings = innerHTML.split('\n')
    for string in strings:
      for str_to_replace in substrings_outside_of_curly_braces(string):
        str_to_replace = str_to_replace.lstrip().rstrip()

        already_translated = str_to_replace[:7] == '{{ $t("'
        is_variable = ((str_to_replace[:2] == "{{") and (str_to_replace[-2:] == "}}"))
        no_letter = not bool(re.search('[a-zA-Z]', str_to_replace))
      
        if already_translated or is_variable or no_letter:
          # This segment was already translated.
          pass
        else:
          print('\n')
          acceptStr = ""
          while acceptStr not in ["Y", "y", "N", "n"]:
            acceptStr = input(f'Add "{str_to_replace}" ? y/n: ')
            if acceptStr in ["N", "n"]:
              print("Not added.")
              break
            elif acceptStr in ["Y", "y"]:
              add_to_json(str_to_replace)
              replace_in_file(path_of_file_to_translate, html_lines, templateElement, str_to_replace)
            else:
              print("Wrong command.")
  print('\n')


def get_file_path():
  
  gross_path = input("Enter the path of file to translate :\n")
  path_of_file_to_translate = os.path.join(BASE_DIR, gross_path.split("src/")[1])
  
  html_doc = open(path_of_file_to_translate, "r+")
  soup = BeautifulSoup(html_doc, 'html.parser')
  html_doc.close()

  html_doc = open(path_of_file_to_translate, "r+")
  html_lines = html_doc.readlines()
  html_doc.close()

  get_strings(path_of_file_to_translate, soup, html_lines)


get_file_path()