module ApplicationHelper
  def money(n)
    if n > 0
      return "<span class='pos'>$#{number_with_delimiter('%.2f' % n)}</span>".html_safe
    else
      return "<span class='neg'>$#{number_with_delimiter('%.2f' % n)}</span>".html_safe
    end
  end
  def num_class(n)
    if n > 0
      return "pos"
    else
      return "neg"
    end
  end
end
