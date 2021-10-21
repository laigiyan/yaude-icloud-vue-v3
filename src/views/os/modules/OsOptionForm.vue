<template>
  <a-spin :spinning="confirmLoading">
    <j-form-container :disabled="formDisabled">
      <a-form-model ref="form" :model="model" :rules="validatorRules" slot="detail">
        <a-row>
         <!-- <a-col :span="24">
            <a-form-model-item label="申請表id" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="applyId">
              <a-input v-model="model.applyId" placeholder="請輸入申請表id"  ></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="審核意見" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="optionsText">
              <a-input v-model="model.optionsText" placeholder="請輸入審核意見"  ></a-input>
            </a-form-model-item>
          </a-col>-->
          <os-apply-form ref="realForm" @ok="submitCallback" :disabled="disableSubmit"></os-apply-form>
          <a-col :span="24">
            <a-form-model-item label="是否同意" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="optionsType">
              <a-input v-model="model.optionsType" placeholder="請輸入是否同意"  ></a-input>
            </a-form-model-item>
          </a-col>
        </a-row>
      </a-form-model>
    </j-form-container>
  </a-spin>
</template>

<script>

  import { httpAction, getAction } from '@/api/manage'
  import { validateDuplicateValue } from '@/utils/util'

  export default {
    name: 'OsOptionForm',
    components: {
    },
    props: {
      //表單禁用
      disabled: {
        type: Boolean,
        default: false,
        required: false
      }
    },
    data () {
      return {
        model:{
        },
        labelCol: {
          xs: { span: 24 },
          sm: { span: 5 },
        },
        wrapperCol: {
          xs: { span: 24 },
          sm: { span: 16 },
        },
        confirmLoading: false,
        validatorRules: {
          applyId: [
            { required: true, message: '請輸入申請表id!'},
          ],
        },
        url: {
          add: "/os/osOption/add",
          edit: "/os/osOption/edit",
          queryById: "/os/osOption/queryById"
        }
      }
    },
    computed: {
      formDisabled(){
        return this.disabled
      },
    },
    created () {
      //備份model原始值
      this.modelDefault = JSON.parse(JSON.stringify(this.model));
    },
    methods: {
      add () {
        this.edit(this.modelDefault);
      },
      edit (record) {
        this.model = Object.assign({}, record);
        this.visible = true;
      },
      submitForm () {
        const that = this;
        // 觸發表單驗證
        this.$refs.form.validate(valid => {
          if (valid) {
            that.confirmLoading = true;
            let httpurl = '';
            let method = '';
            if(!this.model.id){
              httpurl+=this.url.add;
              method = 'post';
            }else{
              httpurl+=this.url.edit;
              method = 'put';
            }
            httpAction(httpurl,this.model,method).then((res)=>{
              if(res.success){
                that.$message.success(res.message);
                that.$emit('ok');
              }else{
                that.$message.warning(res.message);
              }
            }).finally(() => {
              that.confirmLoading = false;
            })
          }

        })
      },
    }
  }
</script>