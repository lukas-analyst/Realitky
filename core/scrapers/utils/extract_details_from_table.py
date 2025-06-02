def extract_details_from_table(container, row_sel, label_sel, value_sel):
    """
    Extracts details from a table-like structure in the HTML.

    :param container: The HTML container element that holds the table rows.
    :param row_sel: CSS selector for the table rows.
    :param label_sel: CSS selector for the labels within the rows.
    :param value_sel: CSS selector for the values within the rows.
    :return: A dictionary with labels as keys and values as values.
    """
    details = {}
    for row in container.css(row_sel):
        label = row.css_first(label_sel)
        value = row.css_first(value_sel)
        if label and value:
            details[label.text(strip=True)] = value.text(strip=True)
    return details