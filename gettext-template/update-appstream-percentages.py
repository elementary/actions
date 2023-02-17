from translate.storage import factory
import lxml.etree as etree
import argparse
import glob

argparser = argparse.ArgumentParser()
argparser.add_argument('file', type=argparse.FileType('r'))
argparser.add_argument('--native-language', default='en')
args = argparser.parse_args()

po_files = glob.glob("po/*.po")
lang_keys = [filename.replace("po/", "").replace(".po", "")
             for filename in po_files]

completion_map = {args.native_language: "100"}

def percent(denominator, divisor):
    if divisor == 0:
        return 0
    else:
        return denominator * 100 / divisor


for key in lang_keys:
    try:
        store = factory.getobject(f"po/{key}.po")
    except ValueError as e:
        continue

    units = [unit for unit in store.units if unit.source]
    translated = [unit for unit in store.units if unit.istranslated()]

    completion_map[key] = round(percent(len(translated), len(units)))

appstream_tree = etree.parse(args.file)
appstream_root = appstream_tree.getroot()
for elem in appstream_root.findall("languages"):
    elem.getparent().remove(elem)

languages = etree.SubElement(appstream_root, "languages")
for k, v in completion_map.items():
    etree.SubElement(languages, "lang", {"percentage": str(v)}).text = k

etree.indent(appstream_root)
appstream_tree.write(args.file.name, encoding="utf-8", xml_declaration=True, pretty_print=True)
