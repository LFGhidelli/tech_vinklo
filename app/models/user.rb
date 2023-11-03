class User < ApplicationRecord
  validates :email, format: { with: /\A\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+\z/}, uniqueness: { case_sensitive: false, message: "já existe" }

  validates :cpf, uniqueness: { case_sensitive: false, message: "CPF já existe" }
  validates :phone, uniqueness: { case_sensitive: false, message: "Número de telefone já existe" }

  validate :cpf_valid?
  validate :phone_valid?
  before_validation :downcase_email
  # validate :format_phone

  # before_validation :sanitize_phone_number
  # def sanitize_phone_number
  #   self.phone = self.phone.gsub(/\D/, '') if self.phone
  # end

  def all_elements_equal?(array)
    first_element = array[0]
    array.all? { |element| element == first_element }
  end

  def cpf_valid?
    cpf = self.cpf
    cpf_pattern = /^\d{3}\.\d{3}\.\d{3}-\d{2}$/

    new_cpf = []
    weight = [10, 9, 8, 7, 6, 5, 4, 3, 2]
    weight_second = [11, 10, 9, 8, 7, 6, 5, 4, 3, 2]
    sum_first = 0
    sum_second = 0

    if cpf == ''
      errors.add(:cpf, 'em branco')
    elsif cpf !~ cpf_pattern
      errors.add(:cpf, 'em formato errado')
    else
      cpf.each_char do |char|
        new_cpf.push(char) if char =~ /\d/ # somente digitos
      end

      if all_elements_equal?(new_cpf) # 111.111.111-11 ou 222.222.222-22 não valem
        errors.add(:cpf, 'inválido')
        return
      end

      new_cpf = new_cpf.first(weight.length)
      # min_length = [new_cpf.length, weight.length].min
      # new_cpf = new_cpf.first(min_length)
      # weight = weight.first(min_length)

      new_cpf.each_with_index do |digit, i|
        sum_first += digit.to_i * weight[i]
      end

      valid_first = (sum_first * 10) % 11

      test_cpf = new_cpf + [valid_first.to_s]

      test_cpf.each_with_index do |digit, i|
        sum_second += digit.to_i * weight_second[i]
      end

      valid_second = (sum_second * 10) % 11

      if valid_second == 10
        valid_second = 0
      end

      unless valid_first == cpf[-2].to_i && valid_second == cpf[-1].to_i
        errors.add(:cpf, 'inválido')
      end
    end
  end

  def phone_valid?
    phone_number = self.phone.delete(" \t\n")
    area_code = %w[
      11 12 13 14 15 16 17 18 19
      21 22 24
      27 28
      31 32 33 34 35 37 38
      41 42 43 44 45 46
      47 48 49
      51 53 54 55
      61 62 63 64 65 66 67 68 69
      71 73 74 75 77
      79
      81 82 83 84 85 86 87 88 89
      91 93 94 95 96 97 98 99
    ]

    area_number = phone_number[0..1]
    no_area_number = phone_number[2..-1]

    unless phone_number.chars.all? { |d| d =~ /\d/ }
      errors.add(:phone, 'inválido')
      return
    end

    if phone_number.empty?
      errors.add(:phone, ' em branco')
    elsif !area_code.include?(area_number)
      errors.add(:phone, ' com DDD inválido')
    elsif phone_number.length != 11
      errors.add(:phone, 'com o tamanho incorreto')
    elsif no_area_number[0] != '9'
      errors.add(:phone, 'faltando o 9')
    end

    formatted_phone = "#{phone_number[0..1]} #{phone_number[2]} #{phone_number[3..6]} #{phone_number[7..10]}"
    self.phone = formatted_phone

    # if !area_code.include?(area_number) || phone_number.length != 11 || phone_number.empty?
    #   errors.add(:phone, 'DDD inválido')
    # else
    #   if no_area_number[0] != '9'
    #     errors.add(:phone, 'inválido')
    #   end
    # end

  end

  # def format_phone
  #   digits = self.phone.gsub(/\D/, '') # remover todos nao digitos
  #   formatted_phone = "#{phone_number[0..1]} #{phone_number[2]} #{phone_number[3..6]} #{phone_number[7..10]}"
  #   self.phone = formatted_phone
  # end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
