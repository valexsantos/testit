# encoding: utf-8

module TestitCommonHelper
  unloadable

  def testit_breadcrumb(*args)
    elements = args.flatten
    elements.any? ? content_tag('p', args.join(" \xc2\xbb ").html_safe, :class => 'breadcrumb') : nil
  end
end
