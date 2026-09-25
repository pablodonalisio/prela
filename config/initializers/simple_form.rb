# frozen_string_literal: true

# Wrapper names match the previous Bootstrap setup so existing `f.input` calls
# do not need to change.

SimpleForm.setup do |config|
  input = "block w-full rounded-lg border border-default bg-neutral-secondary-medium p-2.5 text-sm text-heading placeholder:text-body-subtle focus:border-brand focus:ring-brand"
  select = input
  checkbox = "h-4 w-4 rounded border-default bg-neutral-secondary-medium text-brand focus:ring-2 focus:ring-brand"
  label = "mb-2 block text-sm font-medium text-heading"
  hint = "mt-2 text-sm text-body-subtle"
  error = "mt-2 text-sm text-fg-danger"
  wrapper = "mb-5"
  error_input = "!border-red-500"

  # Keep in sync with ApplicationHelper::FLOWBITE_BUTTON_CLASSES.
  config.button_class = "inline-flex items-center justify-center rounded-lg bg-brand px-5 py-2.5 text-sm font-medium text-white transition-colors hover:bg-brand-strong focus:ring-4 focus:ring-brand-soft"
  config.boolean_label_class = "text-sm font-medium text-heading"
  config.label_text = lambda { |label_text, required, _explicit| "#{label_text} #{required}" }
  config.boolean_style = :inline
  config.item_wrapper_tag = :div
  config.include_default_input_wrapper_class = false
  config.error_notification_tag = :div
  config.error_notification_class = "mb-4 rounded-lg border border-red-300 bg-red-50 p-4 text-sm text-red-800 dark:border-red-800 dark:bg-gray-800 dark:text-red-400"
  config.error_method = :to_sentence
  config.input_field_error_class = error_input
  config.input_field_valid_class = nil
  config.browser_validations = false

  config.wrappers :vertical_form, class: wrapper do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: label
    b.use :input, class: input, error_class: error_input
    b.use :full_error, wrap_with: {class: error}
    b.use :hint, wrap_with: {class: hint}
  end

  config.wrappers :vertical_boolean, tag: :fieldset, class: wrapper do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :form_check_wrapper, class: "flex items-center gap-2" do |bb|
      bb.use :input, class: checkbox, error_class: error_input
      bb.use :label, class: "text-sm font-medium text-heading"
      bb.use :full_error, wrap_with: {class: error}
      bb.use :hint, wrap_with: {class: hint}
    end
  end

  config.wrappers :vertical_collection, item_wrapper_class: "mb-2 flex items-center gap-2", item_label_class: "text-sm font-medium text-heading", tag: :fieldset, class: wrapper do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :legend_tag, tag: :legend, class: "mb-2 text-sm font-medium text-heading" do |ba|
      ba.use :label_text
    end
    b.use :input, class: checkbox, error_class: error_input
    b.use :full_error, wrap_with: {class: error}
    b.use :hint, wrap_with: {class: hint}
  end

  config.wrappers :vertical_collection_inline, item_wrapper_class: "me-4 inline-flex items-center gap-2", item_label_class: "text-sm font-medium text-heading", tag: :fieldset, class: wrapper do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :legend_tag, tag: :legend, class: "mb-2 text-sm font-medium text-heading" do |ba|
      ba.use :label_text
    end
    b.use :input, class: checkbox, error_class: error_input
    b.use :full_error, wrap_with: {class: error}
    b.use :hint, wrap_with: {class: hint}
  end

  config.wrappers :vertical_file, class: wrapper do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :readonly
    b.use :label, class: label
    b.use :input, class: "block w-full cursor-pointer rounded-lg border border-default bg-neutral-secondary-medium text-sm text-body file:me-4 file:border-0 file:bg-neutral-tertiary file:px-4 file:py-2.5 file:text-sm file:font-medium file:text-heading", error_class: error_input
    b.use :full_error, wrap_with: {class: error}
    b.use :hint, wrap_with: {class: hint}
  end

  config.wrappers :vertical_select, class: wrapper do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: label
    b.use :input, class: select, error_class: error_input
    b.use :full_error, wrap_with: {class: error}
    b.use :hint, wrap_with: {class: hint}
  end

  config.wrappers :vertical_multi_select, class: wrapper do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: label
    b.wrapper class: "flex items-center gap-2" do |ba|
      ba.use :input, class: select, error_class: error_input
    end
    b.use :full_error, wrap_with: {class: error}
    b.use :hint, wrap_with: {class: hint}
  end

  config.wrappers :vertical_range, class: wrapper do |b|
    b.use :html5
    b.use :placeholder
    b.optional :readonly
    b.optional :step
    b.use :label, class: label
    b.use :input, class: "h-2 w-full cursor-pointer appearance-none rounded-lg bg-neutral-tertiary accent-brand", error_class: error_input
    b.use :full_error, wrap_with: {class: error}
    b.use :hint, wrap_with: {class: hint}
  end

  config.wrappers :horizontal_form, class: "mb-5 grid grid-cols-1 items-center gap-2 sm:grid-cols-3" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: "text-sm font-medium text-heading sm:mb-0 sm:text-right"
    b.wrapper :grid_wrapper, class: "sm:col-span-2" do |ba|
      ba.use :input, class: input, error_class: error_input
      ba.use :full_error, wrap_with: {class: error}
      ba.use :hint, wrap_with: {class: hint}
    end
  end

  config.wrappers :horizontal_boolean, class: "mb-5 grid grid-cols-1 gap-2 sm:grid-cols-3" do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :grid_wrapper, class: "sm:col-span-2 sm:col-start-2" do |wr|
      wr.wrapper :form_check_wrapper, class: "flex items-center gap-2" do |bb|
        bb.use :input, class: checkbox, error_class: error_input
        bb.use :label, class: "text-sm font-medium text-heading"
        bb.use :full_error, wrap_with: {class: error}
        bb.use :hint, wrap_with: {class: hint}
      end
    end
  end

  config.wrappers :horizontal_collection, item_wrapper_class: "mb-2 flex items-center gap-2", item_label_class: "text-sm font-medium text-heading", class: "mb-5 grid grid-cols-1 gap-2 sm:grid-cols-3" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "text-sm font-medium text-heading sm:pt-1 sm:text-right"
    b.wrapper :grid_wrapper, class: "sm:col-span-2" do |ba|
      ba.use :input, class: checkbox, error_class: error_input
      ba.use :full_error, wrap_with: {class: error}
      ba.use :hint, wrap_with: {class: hint}
    end
  end

  config.wrappers :horizontal_collection_inline, item_wrapper_class: "me-4 inline-flex items-center gap-2", item_label_class: "text-sm font-medium text-heading", class: "mb-5 grid grid-cols-1 gap-2 sm:grid-cols-3" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "text-sm font-medium text-heading sm:pt-1 sm:text-right"
    b.wrapper :grid_wrapper, class: "sm:col-span-2" do |ba|
      ba.use :input, class: checkbox, error_class: error_input
      ba.use :full_error, wrap_with: {class: error}
      ba.use :hint, wrap_with: {class: hint}
    end
  end

  config.wrappers :horizontal_file, class: "mb-5 grid grid-cols-1 items-center gap-2 sm:grid-cols-3" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :readonly
    b.use :label, class: "text-sm font-medium text-heading sm:mb-0 sm:text-right"
    b.wrapper :grid_wrapper, class: "sm:col-span-2" do |ba|
      ba.use :input, class: "block w-full cursor-pointer rounded-lg border border-default bg-neutral-secondary-medium text-sm text-body", error_class: error_input
      ba.use :full_error, wrap_with: {class: error}
      ba.use :hint, wrap_with: {class: hint}
    end
  end

  config.wrappers :horizontal_select, class: "mb-5 grid grid-cols-1 items-center gap-2 sm:grid-cols-3" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "text-sm font-medium text-heading sm:mb-0 sm:text-right"
    b.wrapper :grid_wrapper, class: "sm:col-span-2" do |ba|
      ba.use :input, class: select, error_class: error_input
      ba.use :full_error, wrap_with: {class: error}
      ba.use :hint, wrap_with: {class: hint}
    end
  end

  config.wrappers :horizontal_multi_select, class: "mb-5 grid grid-cols-1 items-center gap-2 sm:grid-cols-3" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "text-sm font-medium text-heading sm:mb-0 sm:text-right"
    b.wrapper :grid_wrapper, class: "sm:col-span-2" do |ba|
      ba.wrapper class: "flex items-center gap-2" do |bb|
        bb.use :input, class: select, error_class: error_input
      end
      ba.use :full_error, wrap_with: {class: error}
      ba.use :hint, wrap_with: {class: hint}
    end
  end

  config.wrappers :horizontal_range, class: "mb-5 grid grid-cols-1 items-center gap-2 sm:grid-cols-3" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :readonly
    b.optional :step
    b.use :label, class: "text-sm font-medium text-heading sm:mb-0 sm:text-right"
    b.wrapper :grid_wrapper, class: "sm:col-span-2" do |ba|
      ba.use :input, class: "h-2 w-full cursor-pointer appearance-none rounded-lg bg-neutral-tertiary accent-brand", error_class: error_input
      ba.use :full_error, wrap_with: {class: error}
      ba.use :hint, wrap_with: {class: hint}
    end
  end

  config.wrappers :inline_form, class: "w-full" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: "sr-only"
    b.use :input, class: input, error_class: error_input
    b.use :error, wrap_with: {class: error}
    b.optional :hint, wrap_with: {class: hint}
  end

  config.wrappers :inline_boolean, class: "w-full" do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :form_check_wrapper, class: "flex items-center gap-2" do |bb|
      bb.use :input, class: checkbox, error_class: error_input
      bb.use :label, class: "text-sm font-medium text-heading"
      bb.use :error, wrap_with: {class: error}
      bb.optional :hint, wrap_with: {class: hint}
    end
  end

  config.wrappers :custom_boolean_switch, class: wrapper do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :form_check_wrapper, tag: :label, class: "inline-flex cursor-pointer items-center gap-3" do |bb|
      bb.use :input, class: "peer sr-only", error_class: error_input
      bb.wrapper tag: :span, class: "relative h-6 w-11 rounded-full bg-gray-200 after:absolute after:start-[2px] after:top-[2px] after:h-5 after:w-5 after:rounded-full after:border after:border-gray-300 after:bg-white after:transition-all after:content-[''] peer-checked:bg-brand peer-checked:after:translate-x-full peer-checked:after:border-white peer-focus:ring-4 peer-focus:ring-brand-soft dark:bg-gray-700" do |bc|
      end
      bb.use :label, class: "text-sm font-medium text-heading"
      bb.use :full_error, wrap_with: {class: error}
      bb.use :hint, wrap_with: {class: hint}
    end
  end

  config.wrappers :input_group, class: wrapper do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: label
    b.wrapper :input_group_tag, class: "flex" do |ba|
      ba.optional :prepend
      ba.use :input, class: "#{input} rounded-e-none", error_class: error_input
      ba.optional :append
      ba.use :full_error, wrap_with: {class: error}
    end
    b.use :hint, wrap_with: {class: hint}
  end

  config.wrappers :floating_labels_form, class: wrapper do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: label
    b.use :input, class: input, error_class: error_input
    b.use :full_error, wrap_with: {class: error}
    b.use :hint, wrap_with: {class: hint}
  end

  config.wrappers :floating_labels_select, class: wrapper do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: label
    b.use :input, class: select, error_class: error_input
    b.use :full_error, wrap_with: {class: error}
    b.use :hint, wrap_with: {class: hint}
  end

  config.default_wrapper = :vertical_form

  config.wrapper_mappings = {
    boolean: :vertical_boolean,
    check_boxes: :vertical_collection,
    date: :vertical_multi_select,
    datetime: :vertical_multi_select,
    file: :vertical_file,
    radio_buttons: :vertical_collection,
    range: :vertical_range,
    time: :vertical_multi_select,
    select: :vertical_select
  }
end
