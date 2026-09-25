// Keep in sync with app/views/shared/_select_dropdown.html.erb.
// Native <option> lists are painted by the OS and cannot use Flowbite tokens.

export const SELECT_BUTTON_CLASSES =
  "inline-flex w-full items-center justify-between rounded-lg border border-default bg-neutral-secondary-medium p-2.5 text-sm text-heading hover:bg-neutral-tertiary focus:border-brand focus:ring-brand";

export const SELECT_MENU_CLASSES =
  "z-50 hidden max-h-56 overflow-y-auto rounded-base border border-default bg-neutral-secondary-medium shadow-sm";

export const SELECT_LIST_CLASSES = "py-2 text-sm text-heading";

export const SELECT_OPTION_CLASSES =
  "block min-h-9 w-full truncate px-4 py-2 text-left hover:bg-neutral-tertiary-medium hover:text-heading";

export const SELECT_OPTION_SELECTED_CLASS = "bg-neutral-tertiary-medium";
