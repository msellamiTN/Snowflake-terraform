#!/usr/bin/env python3
"""Enhance course labs with icons and collapsible OS sections."""
import re
import os
import glob

ROOT = r"D:\Data2AI Academy\Snowflake-terraform\courses"

HEADING_ICONS = [
    (r"^(#) Lab M", r"\1 \U0001F9EA Lab M"),  # 🧪
    (r"^(#) Lab \d", r"\1 \U0001F9EA Lab "),  # 🧪
    (r"^(##) Mission$", r"\1 \U0001F3AF Mission"),  # 🎯
    (r"^(##) Architecture( finale)?$", r"\1 \U0001F3D7\U0000FE0F Architecture"),  # 🏗️
    (r"^(##) Résultat final$", r"\1 \U0001F381 Résultat final"),  # 🎁
    (r"^(##) Résultat attendu$", r"\1 \U0001F381 Résultat attendu"),  # 🎁
    (r"^(##) Objectifs( pédagogiques)?$", r"\1 \U0001F3AF Objectifs\2"),  # 🎯
    (r"^(##) Prérequis( vérifiables)?$", r"\1 \U0001F4CB Prérequis\2"),  # 📋
    (r"^(##) Vue d'ensemble$", r"\1 \U0001F5FA\U0000FE0F Vue d'ensemble"),  # 🗺️
    (r"^(##) Partie \d", r"\1 \U0001F4DD Partie "),  # 📝
    (r"^(###) Étape", r"\1 \U0001F4DD Étape"),  # 📝
    (r"^(##) Challenge$", r"\1 \U0001F3C6 Challenge"),  # 🏆
    (r"^(##) Cleanup( contrôlé)?$", r"\1 \U0001F9F9 Cleanup"),  # 🧹
    (r"^(##) Dépannage$", r"\1 \U0001F527 Dépannage"),  # 🔧
    (r"^(##) Troubleshooting$", r"\1 \U0001F527 Troubleshooting"),  # 🔧
    (r"^(##) Validation finale$", r"\1 \U00002705 Validation finale"),  # ✅
    (r"^(##) Réflexion$", r"\1 \U0001F914 Réflexion"),  # 🤔
    (r"^(##) Préflight$", r"\1 \U0001F680 Préflight"),  # 🚀
    (r"^(##) Erreur contrôlée$", r"\1 \U0001F41B Erreur contrôlée"),  # 🐛
    (r"^(##) Erreurs fréquentes$", r"\1 \U0001F527 Erreurs fréquentes"),  # 🔧
    (r"^(##) Point de reprise$", r"\1 \U0001F3AF Point de reprise"),  # 🎯
    (r"^(##) Commandes utiles$", r"\1 \U0001F527 Commandes utiles"),  # 🔧
]

NOTE_CONVERSIONS = [
    (r"^> \`\[IMPORTANT\]\`", "> ⚠️ **IMPORTANT**"),
    (r"^> \*\*IMPORTANT\*\*", "> ⚠️ **IMPORTANT**"),
    (r"^> \`\[SECURITY\]\`", "> 🔒 **SECURITY**"),
    (r"^> \*\*SECURITY\*\*", "> 🔒 **SECURITY**"),
    (r"^> \`\[COST\]\`", "> 💰 **COST**"),
    (r"^> \`\[NOTE\]\`", "> 💡 **Note**"),
    (r"^> \*\*Note\*\*", "> 💡 **Note**"),
    (r"^> \*\*Pourquoi\*\*", "> 💡 **Pourquoi**"),
    (r"^> \*\*Conseil\*\*", "> 💡 **Conseil**"),
    (r"^> \*\*Attention\*\*", "> ⚠️ **Attention**"),
    (r"^> \*\*Avertissement\*\*", "> ⚠️ **Avertissement**"),
    (r"^> \*\*Si votre résultat diffère\*\*", "> 🔍 **Si votre résultat diffère**"),
    (r"^> \*\*Retour au parcours\*\*", "> 🔗 **Retour au parcours**"),
    (r"^> \*\*Toutes les commandes", "> 📍 **Toutes les commandes"),
]

def has_emoji_prefix(line, heading_level):
    """Check if heading already starts with an emoji."""
    prefix = "#" * heading_level + " "
    if not line.startswith(prefix):
        return False
    rest = line[len(prefix):]
    # simple check for emoji range or common emoji chars
    if rest and (ord(rest[0]) > 0x1F300 or rest[0] in "✅⚠️🔒💰💡🔍🎯🏗️📝🧪🎁📋🗺️🏆🧹🔧🤔🚀🐛🔗📍") :
        return True
    return False

def apply_heading_icons(text):
    lines = text.splitlines()
    out = []
    for line in lines:
        matched = False
        for pattern, repl in HEADING_ICONS:
            if re.match(pattern, line):
                level = len(re.match(r"^#+", line).group(0))
                if not has_emoji_prefix(line, level):
                    new_line = re.sub(pattern, repl, line, count=1)
                    out.append(new_line)
                    matched = True
                    break
        if not matched:
            out.append(line)
    return "\n".join(out)

def apply_note_icons(text):
    lines = text.splitlines()
    out = []
    for line in lines:
        replaced = False
        for pattern, repl in NOTE_CONVERSIONS:
            if re.search(pattern, line):
                out.append(re.sub(pattern, repl, line, count=1))
                replaced = True
                break
        if not replaced:
            out.append(line)
    return "\n".join(out)

def convert_attendu_to_checkpoint(text):
    # Convert **Attendu :** or **Attendu:** to ✅ **Checkpoint** :
    text = re.sub(r"\*\*Attendu\s*:\*\*", "✅ **Checkpoint**", text)
    text = re.sub(r"\*\*\[CHECK\]\s*(?:Attendu)?\s*:\*\*", "✅ **Checkpoint**", text)
    text = re.sub(r"\*\*\[CHECK\]\*\*", "✅ **Checkpoint**", text)
    return text

def is_os_header(line):
    # Return (is_header, os_name) or None
    patterns = [
        (r"^\*\*\[WINDOWS\]\s*(?:PowerShell)?\s*\*\*", "Windows (PowerShell)"),
        (r"^\*\*Windows\s*:\s*\*\*", "Windows (PowerShell)"),
        (r"^\*\*Windows\s*\*\*", "Windows (PowerShell)"),
        (r"^\*\*\[UNIX\]\s*(?:Bash)?\s*\*\*", "Linux/macOS (Bash)"),
        (r"^\*\*Linux/macOS\s*:\s*\*\*", "Linux/macOS (Bash)"),
        (r"^\*\*Linux/macOS\s*\*\*", "Linux/macOS (Bash)"),
    ]
    for pat, name in patterns:
        if re.search(pat, line):
            return (True, name, pat)
    return (False, None, None)

def is_section_boundary(line):
    # True if line marks end of an OS section body
    if not line:
        return False
    # Next OS header
    if is_os_header(line)[0]:
        return True
    # Checkpoint / expected
    if re.search(r"^\*\*\[CHECK\]", line) or re.search(r"^\*\*Attendu\s*:", line):
        return True
    # Next heading
    if re.match(r"^(#{1,3})\s", line):
        return True
    # Blockquote note (usually outside OS section)
    if line.startswith("> "):
        return True
    return False

def convert_os_sections(text):
    lines = text.splitlines()
    out = []
    i = 0
    n = len(lines)
    while i < n:
        line = lines[i]
        is_os, os_name, pat = is_os_header(line)
        if not is_os:
            out.append(line)
            i += 1
            continue
        # Already inside details? skip
        # Collect OS block lines until boundary
        block_lines = [line]
        i += 1
        while i < n:
            cur = lines[i]
            if is_section_boundary(cur):
                break
            block_lines.append(cur)
            i += 1
        # Remove the header line from block content
        body_lines = block_lines[1:]
        # Remove leading empty lines in body
        while body_lines and body_lines[0].strip() == "":
            body_lines.pop(0)
        # Remove trailing empty lines
        while body_lines and body_lines[-1].strip() == "":
            body_lines.pop()
        # Choose icon
        icon = "🪟" if "Windows" in os_name else "🐧"
        out.append(f'<details>')
        out.append(f'<summary>{icon} <b>{os_name}</b></summary>')
        if body_lines:
            out.append("")
            out.extend(body_lines)
            out.append("")
        out.append('</details>')
        out.append("")
    return "\n".join(out)

def collapse_empty_details(text):
    # Remove empty details blocks with no content (if any)
    return re.sub(r'<details>\n<summary>.*?</summary>\n*?</details>\n*', '', text)

def process_file(path):
    with open(path, "r", encoding="utf-8") as f:
        text = f.read()
    original = text
    text = apply_heading_icons(text)
    text = apply_note_icons(text)
    text = convert_attendu_to_checkpoint(text)
    text = convert_os_sections(text)
    # fix multiple blank lines
    text = re.sub(r"\n{3,}", "\n\n", text)
    if text != original:
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
        print(f"Updated: {path}")
    else:
        print(f"No changes: {path}")

def main():
    # Find all lab.md and troubleshooting.md under courses
    for file in glob.glob(os.path.join(ROOT, "**", "lab.md"), recursive=True):
        process_file(file)
    for file in glob.glob(os.path.join(ROOT, "**", "troubleshooting.md"), recursive=True):
        process_file(file)

if __name__ == "__main__":
    main()
