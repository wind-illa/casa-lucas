# app/policies/admin_policy.rb
class AdminPolicy < ApplicationPolicy
  # Este método se usará para autorizar el acceso a cualquier acción dentro del admin.
  def access?
    user.present? && user.administrador?
  end

  class Scope < Scope
    def resolve
      if user.present? && user.administrador?
        scope.all
      else
        scope.none
      end
    end
  end
end
