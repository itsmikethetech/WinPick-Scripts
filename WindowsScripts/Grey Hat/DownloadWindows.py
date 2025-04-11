# NAME: Microsoft Software Download Listing
# DEVELOPER: MASSGRAVE
# DESCRIPTION: Thanks to ❤ MASSGRAVE Drive and MSDN.
# UNDOABLE: No
# UNDO_DESC: Reverts the changes made by this script

import tkinter as tk
from tkinter import ttk, messagebox
import json
import requests
import webbrowser

# Load products and static links from JSON
with open("products.json", "r", encoding="utf-8") as f:
    data = json.load(f)
products = data.get("products", {})
static_links = data.get("static_links", {})

BASE_URL = "https://drive.massgrave.dev/"

# Dark Theme Setup
def set_dark_theme():
    style.theme_use("clam")
    style.configure(".", background="#2b2b2b", foreground="white", fieldbackground="#3c3f41", bordercolor="#5c5c5c")
    style.configure("TButton", background="#3c3f41", foreground="white")
    style.configure("TEntry", fieldbackground="#3c3f41", foreground="white")
    style.configure("TCombobox", fieldbackground="#3c3f41", foreground="white")
    style.configure("TFrame", background="#2b2b2b")

# Main Window Setup with a Header for UI improvement
root = tk.Tk()
root.title("Microsoft Software Download Listing")
root.geometry("900x600")
root.configure(bg="#2b2b2b")

style = ttk.Style()
set_dark_theme()

# Define custom styles for product name labels to match row colors and bold text
style.configure("Even.TLabel", background="#2b2b2b", foreground="white", font=("Helvetica", 14, "bold"), anchor="w")
style.configure("Odd.TLabel", background="#3c3f41", foreground="white", font=("Helvetica", 14, "bold"), anchor="w")

# Top frame (header)
top_frame = ttk.Frame(root, padding=10)
top_frame.pack(fill="x")
header_label = ttk.Label(top_frame, text="Microsoft Software Download Listing", font=("Helvetica", 20, "bold"))
header_label.pack()
tagline_label = ttk.Label(top_frame, text="Select your product to download your copy", font=("Helvetica", 12))
tagline_label.pack()

# Layout Frames
middle_frame = ttk.Frame(root)
middle_frame.pack(fill="both", expand=True, padx=10, pady=10)
bottom_frame = ttk.Frame(root, padding=5)
bottom_frame.pack(fill="x", padx=10, pady=(0, 10))

canvas = tk.Canvas(middle_frame, bg="#2b2b2b", highlightthickness=0)
canvas.pack(side="left", fill="both", expand=True)
scrollbar = ttk.Scrollbar(middle_frame, orient="vertical", command=canvas.yview)
scrollbar.pack(side="right", fill="y")
canvas.configure(yscrollcommand=scrollbar.set)

# Create the list_frame inside the canvas and ensure it stretches across the canvas width
list_frame = ttk.Frame(canvas)
window_item = canvas.create_window((0, 0), window=list_frame, anchor="nw")

def on_frame_configure(event):
    canvas.configure(scrollregion=canvas.bbox("all"))

list_frame.bind("<Configure>", on_frame_configure)

# Bind the canvas's configure event to update the list_frame width
def on_canvas_configure(event):
    canvas.itemconfigure(window_item, width=event.width)
canvas.bind("<Configure>", on_canvas_configure)

# Implement Middle-Mouse Wheel Scrolling (supports Windows and Linux)
def _on_mousewheel(event):
    canvas.yview_scroll(int(-1*(event.delta/120)), "units")
def _on_mousewheel_linux(event):
    if event.num == 4:
        canvas.yview_scroll(-1, "units")
    elif event.num == 5:
        canvas.yview_scroll(1, "units")
canvas.bind_all("<MouseWheel>", _on_mousewheel)
canvas.bind_all("<Button-4>", _on_mousewheel_linux)
canvas.bind_all("<Button-5>", _on_mousewheel_linux)

# -------------------------------
# Product Selection Functions
# -------------------------------
def handle_product(product_id):
    if product_id in static_links:
        show_static_links(product_id)
    else:
        try:
            url = f"https://api.gravesoft.dev/msdl/skuinfo?product_id={product_id}"
            response = requests.get(url)
            response.raise_for_status()
            skus = response.json()["Skus"]
            select_language(skus, product_id)
        except Exception as e:
            messagebox.showerror("Error", f"Failed to fetch languages:\n{e}")

def show_static_links(product_id):
    links_dict = static_links.get(product_id, {})
    product_name = products.get(product_id, "Static Download")
    win = tk.Toplevel(root)
    win.title(f"Select Language - {product_name}")
    win.configure(bg="#2b2b2b")
    ttk.Label(win, text="Choose your language and architecture:", background="#2b2b2b", foreground="white").pack(pady=5)
    lang_var = tk.StringVar()
    lang_dropdown = ttk.Combobox(win, textvariable=lang_var, state="readonly")
    lang_dropdown["values"] = sorted(links_dict.keys())
    lang_dropdown.pack(pady=5, padx=10)
    def submit():
        selection = lang_var.get()
        if not selection:
            return
        full_url = BASE_URL + links_dict[selection]
        confirm = messagebox.askyesno("Confirm Download", f"Do you want to download:\n{selection}?")
        if confirm:
            win.destroy()
            webbrowser.open(full_url)
    ttk.Button(win, text="Download", command=submit).pack(pady=10)

def select_language(skus, product_id):
    lang_window = tk.Toplevel(root)
    lang_window.title("Select Language")
    lang_window.configure(bg="#2b2b2b")
    ttk.Label(lang_window, text="Choose your language:", background="#2b2b2b", foreground="white").pack(pady=5)
    lang_var = tk.StringVar()
    lang_dropdown = ttk.Combobox(lang_window, textvariable=lang_var, state="readonly")
    lang_dropdown["values"] = [f'{sku["LocalizedLanguage"]} (ID: {sku["Id"]})' for sku in skus]
    lang_dropdown.pack(pady=5, padx=10)
    def submit():
        index = lang_dropdown.current()
        if index == -1:
            return
        sku_id = skus[index]["Id"]
        lang_window.destroy()
        fetch_downloads(product_id, sku_id)
    ttk.Button(lang_window, text="Submit", command=submit).pack(pady=10)

def confirm_api_download(url, filename, parent_window):
    confirm = messagebox.askyesno("Confirm Download",
                                  f"Thank you to Microsoft/MSDN for providing this download.\nDo you want to download:\n{filename}?")
    if confirm:
        parent_window.destroy()
        webbrowser.open(url)

def fetch_downloads(product_id, sku_id):
    try:
        url = f"https://api.gravesoft.dev/msdl/proxy?product_id={product_id}&sku_id={sku_id}"
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        if not data.get("ProductDownloadOptions"):
            messagebox.showinfo("No Downloads", "No download options available.")
            return
        dl_window = tk.Toplevel(root)
        dl_window.title("Download Options")
        dl_window.configure(bg="#2b2b2b")
        for option in data["ProductDownloadOptions"]:
            filename = option["Uri"].split("?")[0].split("/")[-1]
            url = option["Uri"]
            btn = ttk.Button(dl_window, text=filename,
                             command=lambda url=url, filename=filename: confirm_api_download(url, filename, dl_window))
            btn.pack(fill="x", padx=10, pady=5)
    except Exception as e:
        messagebox.showerror("Error", f"Failed to fetch downloads:\n{e}")

# -------------------------------
# Product List UI: Vertical List with Enhanced Styling
# -------------------------------
def update_product_list():
    # Clear the current product list
    for widget in list_frame.winfo_children():
        widget.destroy()
    # List all products with alternating row colors for readability
    for idx, (pid, pname) in enumerate(products.items()):
        row_bg = "#2b2b2b" if idx % 2 == 0 else "#3c3f41"
        item_frame = ttk.Frame(list_frame, padding=(10, 5))
        item_frame.pack(fill="x", padx=5, pady=2)
        # Apply manual style to the frame to ensure background color consistency
        item_frame.configure(style="Even.TFrame" if idx % 2 == 0 else "Odd.TFrame")
        # Create a label that stretches and fills available horizontal space
        label_style = "Even.TLabel" if idx % 2 == 0 else "Odd.TLabel"
        label = ttk.Label(item_frame, text=pname, style=label_style)
        label.pack(side="left", fill="x", expand=True)
        btn = ttk.Button(item_frame, text="Select", command=lambda pid=pid: handle_product(pid))
        btn.pack(side="right")
    
# Additional styles for alternating row colors
style.configure("Even.TFrame", background="#2b2b2b")
style.configure("Odd.TFrame", background="#3c3f41")

update_product_list()
root.mainloop()
