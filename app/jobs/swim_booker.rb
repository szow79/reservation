class SwimBooker

  # Book a swimming lane
  def perform(day: "Monday", time: "8:00 am")
    b = Watir::Browser.new(:chrome)
    b.goto("https://members.crunch.com/members/sign_in")
    b.wait_until { b.text_field(id: "login-email").present? }
    b.text_field(id: "login-email").set(Rails.application.secrets.CRUNCH_EMAIL)
    b.text_field(id: "login-password").set(Rails.application.secrets.CRUNCH_PASSWORD)
    b.form(class: "login-form").submit
    sleep(2)
    loop do
      b.goto("https://members.crunch.com/my-classes")
      b.wait_until { b.lis(class: "weektabs-tab").count == 7 }
      b.lis(class: "weektabs-tab").find { |li| li.attribute_value("data-full").downcase == day.downcase }.click
      sleep(5)

      target_div = b.divs(class: "schedules-row").find do |d|
        d.text.downcase.include?("lap swim") && d.text.downcase.include?(time.downcase)
      end

      if target_div.present? && target_div.div(class: "reservations--button-container").present?
        scroll_to_centered(b, target_div.div(class: "reservations--button-container").span, distance_from_top: 300)
        # target_div.div(class: "reservations--button-container").span.click
        p ""
        p "Done reserving!"
        p ""
        sleep(5)
        break
      end
      sleep(10)
    end
  rescue StandardError => e
    p ""
    p "#{e.message}"
    p ""
  ensure
    b.close
  end

  private

  def scroll_to_centered(browser, element, distance_from_top: 150)
    browser.scroll.to([element.wd.location.x, [element.wd.location.y - distance_from_top, 0].max])
    sleep(1)
  end

end
