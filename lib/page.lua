local page = {}

function page.init()
  page.titles = config.page_titles
  page.active_page = 0
  page.error = false
  page.error_code = 0
end

function page:scroll(d)
  self:select(util.clamp(page.active_page + d, 1, #page.titles))
end

function page:select(i)
  self.active_page = i
  menu:reset()
  fn.dirty_screen(true)
end

function page:render()
  graphics:setup()
      if page.error            then self:error_message()
  elseif self.active_page == 1 then self:home()
  elseif self.active_page == 2 then self:cell_designer()
  elseif self.active_page == 3 then self:analysis()
  elseif self.active_page == 4 then glyphs:test()
  elseif self.active_page == 0 then graphics:splash()
  end
  fn.dirty_screen(true)
  graphics:teardown()
end

function page:home()
  local menu_items = { fn.playback() }
  for k,v in pairs(config["home_items"]) do menu_items[k+1] = v end
  menu:set_items(menu_items)
  menu:select_item()
  if popup:is_active() then
    popup:render()
  elseif docs:is_active() then
    graphics:panel()
    menu:render(false)
    graphics:render_docs()
  else
    graphics:panel()
    menu:render()
    graphics:bpm(55, 32, params:get("bpm"), 0)
    graphics:playback_icon(56, 35)
    graphics:icon(76, 35, sound.length, menu.selected_item == 4 and 1 or 0)
    graphics:text(56, 61, mu.note_num_to_name(sound.root) .. " " .. sound.scale_name, 0)
    graphics:rect(126, 55, 2, 7, 15)
  end
  graphics:title_bar_and_tabs()
end

function page:cell_designer()
  if popup:is_active() then
    popup:render()
  else
    if not keeper.is_cell_selected then
      graphics:select_a_cell()
    elseif docs:is_active() then
      graphics:panel()
      menu:render(false)
      graphics:render_docs()
    else
      graphics:panel()
      menu:set_items(keeper.selected_cell:menu_items())
      menu:select_item()
      menu:render()
      graphics:draw_ports()
      graphics:structure_and_title(keeper.selected_cell.structure_value)
    end
  end
  graphics:title_bar_and_tabs()
end

function page:analysis()
  if popup:is_active() then
    popup:render()
  else
    menu:set_items(config.analysis_items)
    menu:select_item()
    graphics:analysis(menu.items, menu.selected_item_string)
  end
  graphics:title_bar_and_tabs()
end

function page:error_message()
  if self.error_code == 1 then
    graphics:grid_connect_error()
  end
end

function page:set_error(i)
  self.error = true
  self.error_code = i
end

function page:clear_error()
  self.error = false
  self.error_code = 0
end

return page