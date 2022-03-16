import os, re, copy
from bs4 import BeautifulSoup

ASK_CONFIRMATION = False

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
I18N_DIR = os.path.join(BASE_DIR, 'i18n')
LOCALES_DIR = os.path.join(BASE_DIR, 'locales')

def output_str(string):
  print(f'\n"{string}"')

def add_to_json(newStr):
  json_doc = open(f"{LOCALES_DIR}/en.json", "r+")
  json_lines = json_doc.readlines()
  for line in json_lines:
    substrings = line.split('"')
    if len(substrings) > 1:
      if newStr == substrings[1]:
        #print('String was already stored.')
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
    #print('Added to en.json')


def substrings_outside_of_curly_braces(string):
  strings_of_interest = []
  gross_substrings = re.split("{{(.+?)}}", string)
  # get rid of odd indexes values (those found between curly braces)
  for i in range(len(gross_substrings)):
    if i % 2 == 0:
      strings_of_interest.append(gross_substrings[i])
  return strings_of_interest


def substrings_outside_of_tag(string):
  strings_of_interest = []
  gross_substrings = re.split("<(.+?)>", string)
  # get rid of odd indexes values (those found between curly braces)
  for i in range(len(gross_substrings)):
    if i % 2 == 0:
      strings_of_interest.append(gross_substrings[i])
  return strings_of_interest


def substrings_inside_of_tag(string):
  strings_of_interest = []
  gross_substrings = re.split("<(.+?)>", string)
  # get rid of odd indexes values (those found between curly braces)
  for i in range(len(gross_substrings)):
    if i % 2 == 1:
      strings_of_interest.append(gross_substrings[i])
  return strings_of_interest

def contains_splitted_string(inner_HTML, line):
  for char in inner_HTML:
    if len(line) == 0:
      return False
    else:
      while line[0] != char:
        line = line[1:]
        if len(line) == 0:
          return False
      line = line[1:]
  return True


def check_str_validity(path_of_file_to_translate, soup, template_element, str_to_replace):
  str_to_replace = str_to_replace.lstrip().rstrip()
  already_translated = str_to_replace[:7] == '{{ $t("'
  if ('"' in str_to_replace) and (not already_translated):
    output_str(str_to_replace)
    print("!!! The string contains double quotes. Replace it manually.\n")
    return False
  else:
    is_variable = ((str_to_replace[:2] == "{{") and (str_to_replace[-2:] == "}}"))
    no_letter = not bool(re.search('[a-zA-Z]', str_to_replace))
    if not ( already_translated or is_variable or no_letter ):
      # String content is eligible for a translation. Prompt the developer to decide.
      #print('\n')
      acceptStr = ""
      while acceptStr not in ["Y", "y", "N", "n"]:
        if ASK_CONFIRMATION:
          acceptStr = input(f'Translate "{str_to_replace}" ? y/n: ')
        else:
          acceptStr = "y"
        if acceptStr in ["N", "n"]:
          #print("Skipped.")
          break
        elif acceptStr in ["Y", "y"]:
          return replace_in_file(path_of_file_to_translate, soup, template_element, str_to_replace)
        else:
          print("Wrong command.")
  return True


def inner_HTML_is_changed(temp_text, file_text):
  # Make sure it is not the wrong segment that was replaced.
  if substrings_outside_of_curly_braces(temp_text) == substrings_outside_of_curly_braces(file_text):
    # A variable was replaced instead of relevent text
    return False
  if substrings_outside_of_tag(temp_text) == substrings_outside_of_tag(file_text):
    # Tag code was replaced instead of relevent text
    return False
  return True


def is_appropriate_line(searched_str, line):
  outside_of_tag = False
  outside_of_curly_braces = False
  for substring in substrings_outside_of_tag(line):
    if searched_str in substring:
      outside_of_tag = True
  for substring in substrings_outside_of_curly_braces(line):
    if searched_str in substring:
      outside_of_curly_braces = True
  if outside_of_tag and outside_of_curly_braces:
    return True
  else:
    return False


def replace_in_file(path_of_file_to_translate, soup, template_element, original_string):
  
  html_doc = open(path_of_file_to_translate, "r+")
  html_lines = html_doc.readlines()
  html_doc.close()
  
  new_string = '{{ $t("%s")}}' % (original_string)
  for idx, line in enumerate(html_lines):
    if is_appropriate_line(original_string, line):
      patterns_in_line = len(re.findall(re.escape(original_string),line))
      for i in range(patterns_in_line):
        temp_lines = copy.copy(html_lines)
        original_line = html_lines[idx]
        new_line = temp_lines[idx].replace(original_string, new_string, i+1).replace(new_string, original_string, i)
        temp_lines[idx] = temp_lines[idx].replace(original_string, new_string, i+1).replace(new_string, original_string, i)
        temp_doc = open(f"{I18N_DIR}/temp.html", "r+")
        temp_doc.write("".join(temp_lines))
        temp_doc.close()
        temp_doc = open(f"{I18N_DIR}/temp.html", "r+")
        temp_soup = BeautifulSoup(temp_doc, 'html.parser')
        temp_text = temp_soup.find_all()[0].text
        temp_doc.close()
        if inner_HTML_is_changed(temp_text, template_element.text) and substrings_inside_of_tag(new_line) == substrings_inside_of_tag(original_line):
          html_doc = open(path_of_file_to_translate, "r+")
          html_doc.write("".join(temp_lines))
          html_doc.close()
          #print('Text is replaced.')
          add_to_json(original_string)
          return True
        else:
          print("innerHTML not changed")
  # No line in was matching the innerHTML -> HTML line probably contains a tag (doesn't appear in template_element.text)
  output_str(original_string)
  print('This pattern is actually splitted into several segments in the HTML (see next suggested segments).')
  for line in html_lines:
    if contains_splitted_string(original_string, line):
      print(f"SUBSTRING: \n{line}")
      for substring in substrings_outside_of_tag(line):
        for clean_substring in substrings_outside_of_curly_braces(substring):
          check_str_validity(path_of_file_to_translate, soup, template_element, clean_substring)
      return True
  print("!!! UNEXPECTED: Failed to replace string in component !!!\n")
  return False



def iterate_through_substrings(path_of_file_to_translate, soup, template_element, string):
  for str_to_replace in substrings_outside_of_curly_braces(string):
    if not check_str_validity(path_of_file_to_translate, soup, template_element, str_to_replace):
      return False
  return True

def get_strings(path_of_file_to_translate, soup):
  template_element = soup.find_all()[0]
  innerHTML = template_element.text
  # check presence of letters in substring:
  if bool(re.search('[a-zA-Z]', innerHTML)):
    strings = innerHTML.split('\n')
    for string in strings:
      if not iterate_through_substrings(path_of_file_to_translate, soup, template_element, string):
        break

def get_file_path():

  gross_path = input("Enter the path of file to translate :\n")
  path_of_file_to_translate = os.path.join(BASE_DIR, gross_path.split("src/")[1])

  html_doc = open(path_of_file_to_translate, "r+")
  soup = BeautifulSoup(html_doc, 'html.parser')
  html_doc.close()

  get_strings(path_of_file_to_translate, soup)


get_file_path()